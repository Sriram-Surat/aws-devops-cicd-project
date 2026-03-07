pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "suratdochub/project-2026"
    }

    stages {

        stage('Clone Repository') {
            steps {
                git 'https://github.com/Sriram-Surat/aws-devops-cicd-project.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE ./app'
            }
        }

        stage('Push Docker Image') {
            steps {
                sh 'docker push $DOCKER_IMAGE'
            }
        }

    }
}