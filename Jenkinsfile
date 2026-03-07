pipeline {
agent any

environment {
    DOCKER_IMAGE = "suratdochub/project-2026"
}

stages {

    stage('Terraform Init') {
        steps {
            dir('terraform') {
                bat 'terraform init'
            }
        }
    }

    stage('Terraform Apply') {
        steps {
            dir('terraform') {
                bat 'terraform apply -auto-approve'
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
