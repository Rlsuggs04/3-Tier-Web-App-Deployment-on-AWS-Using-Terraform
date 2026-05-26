# 3-Tier-Web-App-Deployment-on-AWS-Using-Terraform
This project demonstrates the deployment of a scalable and secure 3-tier web application architecture on AWS using IaC principles with Terraform.  The architecture follows a clean separation of concerns between the presentation, application, and database layers to improve scalability, maintainability, and operational reliability. 

## Architecture Overview

The environment is deployed within a custom Amazon VPC utilizing both public and private subnets to improve security and network segmentation.

### Presentation Layer
- Hosted on Amazon EC2
- Serves the frontend web application
- Handles user interaction and HTTPS requests

### Application Layer
- Hosted on Amazon EC2
- Processes business logic and API requests
- Manages authentication and review workflows

### Data Layer
- Amazon RDS MySQL database
- Stores user account information, book data, and reviews
- Deployed in private subnets for additional security

## Technologies Used

- Terraform
- AWS EC2
- Amazon RDS (MySQL)
- Amazon VPC
- Public & Private Subnets
- Security Groups
- IAM
- Route Tables
- Internet Gateway
- Linux
- HTML / CSS / JavaScript

## Key Features

- Infrastructure provisioning using Terraform
- Secure VPC network design
- Public/private subnet architecture
- Least privilege IAM configuration
- User authentication workflows
- API-driven communication between application layers
- Scalable 3-tier architecture design
- Cloud infrastructure automation

## Goals of This Project

This project was built to strengthen hands-on experience with:
- Cloud infrastructure engineering
- AWS architecture design
- Infrastructure as Code (IaC)
- Networking and security concepts
- Terraform automation
- DevOps and deployment workflows

## Future Improvements

- Load balancing and auto scaling
- CI/CD pipeline integration
- Docker containerization
- Monitoring and centralized logging
- HTTPS certificate automation
- WAF integration
- Refactor the code using modules
