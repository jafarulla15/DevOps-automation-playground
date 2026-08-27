pipeline {

    agent any

    environment {
        IMAGE_NAME      = "demo-angular-app"
        CONTAINER_NAME  = "demo-angular-app"
        HOST_PORT       = "4600"
        CONTAINER_PORT  = "80"

        GIT_REPO_URL        = "https://github.com/jafarulla15/DevOps-Demo-Angular.git"
        GIT_BRANCH          = "main"
        GIT_CREDENTIALS_ID  = "github-jenkins-pat"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: "${GIT_BRANCH}",
                    credentialsId: "${GIT_CREDENTIALS_ID}",
                    url: "${GIT_REPO_URL}"
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    npm ci
                '''
            }
        }

        stage('Build Angular') {
            steps {
                sh '''
                    npm run build
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                      -t ${IMAGE_NAME}:${BUILD_NUMBER} \
                      -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Stop Existing Container') {
            steps {
                sh '''
                    docker rm -f ${CONTAINER_NAME} || true
                '''
            }
        }

        stage('Run Angular') {
            steps {
                sh '''
                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      -p ${HOST_PORT}:${CONTAINER_PORT} \
                      ${IMAGE_NAME}:latest
                '''
            }
        }
    }

    post {

        success {
            echo '======================================'
            echo 'Angular deployment successful'
            echo '======================================'
        }

        failure {
            echo 'Angular pipeline failed'
        }

        always {
            cleanWs()
        }
    }
}
