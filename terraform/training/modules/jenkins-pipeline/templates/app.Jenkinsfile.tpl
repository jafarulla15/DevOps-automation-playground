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
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: "${git_branch}",
                    credentialsId: "${git_credentials_id}",
                    url: "${git_repository_url}"
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                      -t $IMAGE_NAME:$BUILD_NUMBER \
                      -t $IMAGE_NAME:latest .
                '''
            }
        }

        stage('Stop Existing Container') {
            steps {
                sh '''
                    docker rm -f $CONTAINER_NAME || true
                '''
            }
        }

        stage('Run Application') {
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
