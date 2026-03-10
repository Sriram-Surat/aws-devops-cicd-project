# AWS DevOps CI/CD Pipeline Project

This project demonstrates a complete DevOps automation workflow using AWS and modern DevOps tools.

## Tools Used

- GitHub
- Jenkins
- Terraform
- Docker
- AWS (VPC, ALB, Auto Scaling, S3)

## Architecture

Developer pushes code → GitHub → Jenkins Pipeline → Docker Build  → Docker push to Dockerhub → Terraform Infrastructure → Deploy to AWS Auto Scaling Group behind ALB.

## Deployment Flow

1. Jenkins pulls code from GitHub
2. Docker image is built
3. Image pushed to DockerHub
4. Terraform creates AWS infrastructure
5. Docker Image pulled from Dockerhub in the created Infra
6. Application deployed to EC2 instances
7. Users access application through Load Balancer

## Commands

terraform init  
terraform plan  
terraform apply
