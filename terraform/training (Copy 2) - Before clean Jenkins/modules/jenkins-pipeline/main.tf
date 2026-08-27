resource "jenkins_credential" "git" {
  name = var.git_credentials_id

  username = var.git_username

  password = var.git_token

  description = "Git repository access"
}

resource "jenkins_job" "application_pipeline" {
  name = var.job_name

  depends_on = [
    jenkins_credential.git
  ]

  template = <<-EOT
<flow-definition plugin="workflow-job">
  <actions/>

  <description>
    Terraform managed CI/CD pipeline for ${var.application_name}
  </description>

  <keepDependencies>false</keepDependencies>

  <properties/>

  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition">
    <script>
pipeline {
    agent any

    environment {
        APP_NAME = '${var.application_name}'
        IMAGE_NAME = '${var.docker_registry}/${var.application_name}'
        CONTAINER_NAME = '${var.application_name}'
        APP_PORT = '${var.application_port}'
        HOST_PORT = '${var.host_port}'
    }

    stages {

        stage('Checkout') {
            steps {
                git(
                    branch: '${var.git_branch}',
                    credentialsId: '${var.git_credentials_id}',
                    url: '${var.git_repository_url}'
                )
            }
        }

        stage('Build') {
            steps {
                echo 'Building application...'

                sh '''
                    echo "Application build goes here"
                '''
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'

                sh '''
                    echo "Application tests go here"
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                      -t $IMAGE_NAME:$BUILD_NUMBER \
                      -t $IMAGE_NAME:latest \
                      .
                '''
            }
        }

        stage('Docker Push') {
            steps {
                sh '''
                    docker push $IMAGE_NAME:$BUILD_NUMBER
                    docker push $IMAGE_NAME:latest
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker rm -f $CONTAINER_NAME || true

                    docker run -d \
                      --name $CONTAINER_NAME \
                      --restart unless-stopped \
                      -p $HOST_PORT:$APP_PORT \
                      $IMAGE_NAME:$BUILD_NUMBER
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully.'
        }

        failure {
            echo 'CI/CD pipeline failed.'
        }
    }
}
    </script>

    <sandbox>true</sandbox>
  </definition>

  <triggers/>

  <disabled>false</disabled>
</flow-definition>
EOT
}
