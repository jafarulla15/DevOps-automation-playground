pipeline {

    agent any

%{ if poll_schedule != null ~}
    triggers {
        cron('${poll_schedule}')
    }
%{ endif ~}

    environment {
        IMAGE_NAME      = "${image_name}"
        CONTAINER_NAME  = "${container_name}"
        CONTAINER_PORT  = "${container_port}"
%{ if host_port != null ~}
        HOST_PORT       = "${host_port}"
%{ endif ~}
%{ if deploy_trigger_phrase != null ~}
        DEPLOY_STATE_FILE = "/var/jenkins_home/pipeline-state/${container_name}.sha"
%{ endif ~}
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: "${git_branch}",
                    credentialsId: "${git_credentials_id}",
                    url: "${git_repository_url}"
            }
        }

%{ if deploy_trigger_phrase != null ~}
        stage('Check Deploy Trigger') {
            steps {
                script {
                    def latestCommit = sh(script: 'git log -1 --pretty=%H', returnStdout: true).trim()
                    def commitMessage = sh(script: 'git log -1 --pretty=%B', returnStdout: true).trim()

                    sh 'mkdir -p /var/jenkins_home/pipeline-state'
                    def previousCommit = fileExists(env.DEPLOY_STATE_FILE) ? readFile(env.DEPLOY_STATE_FILE).trim() : ''

                    def isNewCommit = (latestCommit != previousCommit)
                    def hasTriggerPhrase = commitMessage.toLowerCase().contains('${lower(deploy_trigger_phrase)}')

                    env.LATEST_COMMIT = latestCommit
                    env.SHOULD_DEPLOY = (isNewCommit && hasTriggerPhrase) ? 'true' : 'false'

                    echo "Latest commit: $${latestCommit}"
                    echo "Commit message: $${commitMessage}"
                    echo "New commit since last check: $${isNewCommit}"
                    echo "Contains deploy trigger phrase ('${deploy_trigger_phrase}'): $${hasTriggerPhrase}"
                    echo "Will deploy: $${env.SHOULD_DEPLOY}"
                }
            }
        }
%{ endif ~}

        stage('Docker Build') {
%{ if deploy_trigger_phrase != null ~}
            when {
                environment name: 'SHOULD_DEPLOY', value: 'true'
            }
%{ endif ~}
            steps {
                script {
                    env.OLD_IMAGE_ID = sh(script: 'docker images -q $IMAGE_NAME:latest', returnStdout: true).trim()
                }
                sh '''
                    if [ -n "$OLD_IMAGE_ID" ]; then
                        docker tag "$OLD_IMAGE_ID" $IMAGE_NAME:backup
                    fi
                    docker build \
                      -t $IMAGE_NAME:$BUILD_NUMBER \
                      -t $IMAGE_NAME:latest .
                '''
            }
        }

        stage('Stop Existing Container') {
%{ if deploy_trigger_phrase != null ~}
            when {
                environment name: 'SHOULD_DEPLOY', value: 'true'
            }
%{ endif ~}
            steps {
                sh '''
                    docker rm -f $CONTAINER_NAME || true
                '''
            }
        }

        stage('Run Application') {
%{ if deploy_trigger_phrase != null ~}
            when {
                environment name: 'SHOULD_DEPLOY', value: 'true'
            }
%{ endif ~}
            steps {
                sh '''
                    docker run -d \
                      --name $CONTAINER_NAME \
%{ if docker_network != null ~}
                      --network ${docker_network} \
%{ endif ~}
%{ if host_port != null ~}
                      -p $HOST_PORT:$CONTAINER_PORT \
%{ endif ~}
                      $IMAGE_NAME:latest
                '''
            }
        }

        stage('Backup Old Image') {
%{ if deploy_trigger_phrase != null ~}
            when {
                environment name: 'SHOULD_DEPLOY', value: 'true'
            }
%{ endif ~}
            steps {
                sh '''
                    if [ -n "$OLD_IMAGE_ID" ]; then
                        echo "Previous image kept as $IMAGE_NAME:backup ($OLD_IMAGE_ID)"
                    else
                        echo "No previous image - nothing to back up on this build"
                    fi
                '''
            }
        }

%{ if deploy_trigger_phrase != null ~}
        stage('Record Deployed Commit') {
            when {
                environment name: 'SHOULD_DEPLOY', value: 'true'
            }
            steps {
                writeFile file: env.DEPLOY_STATE_FILE, text: env.LATEST_COMMIT
            }
        }
%{ endif ~}
    }

    post {

        success {
            echo '======================================'
            echo '${application_name} deployment successful'
            echo '======================================'
        }

        failure {
            echo '${application_name} pipeline failed'
        }

        always {
            cleanWs()
        }
    }
}
