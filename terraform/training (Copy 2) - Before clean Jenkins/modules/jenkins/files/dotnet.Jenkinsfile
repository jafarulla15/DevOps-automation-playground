pipeline {

    agent any

    environment {
        IMAGE_NAME      = "demo-dotnet-api"
        CONTAINER_NAME  = "demo-dotnet-api"
        HOST_PORT       = "5000"
        CONTAINER_PORT  = "8080"

        GIT_REPO_URL        = "https://github.com/jafarulla15/DevOps-Demo-REST-Api.git"
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

        stage('Restore') {
            steps {
                sh '''
                    dotnet restore
                '''
            }
        }

        stage('Build') {
            steps {
                sh '''
                    dotnet build --configuration Release --no-restore
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    dotnet test --configuration Release --no-build
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

        stage('Run Application') {
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
            echo '.NET API deployment successful'
            echo '======================================'
        }

        failure {
            echo '.NET API pipeline failed'
        }

        always {
            cleanWs()
        }
    }
}
