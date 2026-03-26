pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "suratdochub/aws-devops-cicd-project:${BUILD_NUMBER}"
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Terraform action'
        )
    }

    stages {

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                bat 'docker build -t %DOCKER_IMAGE% .'
            }
        }

        stage('Test') {
    steps {
        echo 'Running container health check...'
        bat '''
        echo Starting container...
        for /f "tokens=*" %%i in ('docker run -d -p 8081:80 %DOCKER_IMAGE%') do set CONTAINER_ID=%%i

        echo Waiting for application to start...
        ping 127.0.0.1 -n 10 > nul

        echo Testing application endpoint...
        curl -f http://localhost:8081 || exit 1

        echo Stopping test container...
        docker stop %CONTAINER_ID%
        docker rm %CONTAINER_ID%
        '''
    }
}

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat '''
                    echo Logging into DockerHub...
                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image...'
                retry(2) {
                    bat 'docker push %DOCKER_IMAGE%'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    echo 'Initializing Terraform...'
                    bat 'terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir('terraform') {
                    echo 'Applying Terraform...'
                    bat 'terraform apply -auto-approve'
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                input message: 'Are you sure you want to destroy infrastructure?'
                dir('terraform') {
                    echo 'Destroying Terraform infrastructure...'
                    bat 'terraform destroy -auto-approve'
                }
            }
        }

        stage('Post-Deploy Health Check') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir('terraform') {
                    echo 'Fetching ALB DNS and validating app...'
                    bat '''
                    for /f "delims=" %%i in ('terraform output -raw alb_dns_name') do set ALB=%%i
                    echo ALB DNS: %ALB%

                    echo Waiting for application to be ready...
                    ping 127.0.0.1 -n 30 > nul

                    curl -f http://%ALB% || exit 1
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker containers...'
            bat 'for /f "tokens=*" %%i in (\'docker ps -aq\') do docker rm -f %%i'
        }

        success {
            echo 'Pipeline executed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check logs.'
        }
    }
}