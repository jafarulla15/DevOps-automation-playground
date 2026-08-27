# Deployment Guide

## 1. Purpose

This document describes how to initialize, validate, plan, and deploy the Terraform infrastructure.

## 2. Prerequisites

Install:

- Ubuntu Linux
- Terraform
- Docker
- Git
- kubectl
- Helm where required

Verify:

    terraform version
    docker version
    git --version
    kubectl version --client

## 3. Clone Repository

    git clone <repository-url>
    cd terraform-infrastructure

## 4. Terraform Initialization

    terraform init

Verify providers:

    terraform providers

## 5. Format

    terraform fmt -recursive

## 6. Validate

    terraform validate

Terraform must return a successful validation result before proceeding.

## 7. Environment Configuration

Select the target environment:

    environments/dev/
    environments/staging/
    environments/prod/

Never accidentally deploy production configuration to development or vice versa.

## 8. Terraform Plan

Generate a plan:

    terraform plan

For environment-specific configuration:

    terraform plan -var-file="dev.tfvars"

Review:

- Resources to create
- Resources to modify
- Resources to destroy
- Network changes
- Storage changes
- Security changes

## 9. Terraform Apply

Apply only after reviewing the plan:

    terraform apply

For an approved saved plan:

    terraform apply tfplan

## 10. Docker Deployment

Verify containers:

    docker ps

Check networks:

    docker network ls

Check volumes:

    docker volume ls

Check logs:

    docker logs <container>

## 11. Jenkins Deployment

Verify Jenkins:

    docker ps | grep jenkins

Verify:

- Jenkins starts
- Plugins installed
- GitHub access works
- Credentials are configured
- Pipeline can run

## 12. Registry Deployment

Verify registry:

    docker ps | grep registry

Test registry connectivity.

The registry should not be publicly exposed unless required.

## 13. Monitoring Deployment

Verify:

    docker ps | grep prometheus
    docker ps | grep grafana
    docker ps | grep loki
    docker ps | grep alertmanager
    docker ps | grep otel

## 14. Application Deployment

Expected application process:

    GitHub
       ↓
    Jenkins
       ↓
    Build
       ↓
    Test
       ↓
    Docker Build
       ↓
    Registry
       ↓
    Deployment
       ↓
    Health Check

## 15. Kubernetes Deployment

Verify cluster:

    kubectl cluster-info
    kubectl get nodes
    kubectl get namespaces

Deploy:

    kubectl apply -f <manifest>

Verify:

    kubectl get pods
    kubectl get services
    kubectl get deployments

## 16. Health Checks

After deployment verify:

- Application endpoint
- API health endpoint
- Database connectivity
- Redis connectivity
- RabbitMQ connectivity
- Vault connectivity
- Metrics endpoint
- Logs
- Alerts

## 17. Rollback

If deployment fails:

1. Stop further deployment.
2. Identify failure.
3. Check Jenkins logs.
4. Check Docker logs.
5. Check Kubernetes events if applicable.
6. Check Terraform plan/state.
7. Restore previous application version.
8. Roll back infrastructure only when required.

## 18. Production Deployment

Production deployment requires:

- Approved Git change
- Reviewed Terraform plan
- Security review
- Backup where applicable
- Monitoring enabled
- Rollback plan
- Explicit approval

## 19. Post Deployment

Verify:

    terraform state list
    docker ps
    docker network ls
    docker volume ls

Application health must be verified.

Monitoring dashboards must be operational.

## 20. Deployment Checklist

- [ ] Git branch verified
- [ ] Terraform initialized
- [ ] Terraform formatted
- [ ] Terraform validated
- [ ] Terraform plan reviewed
- [ ] Security reviewed
- [ ] Backup verified where applicable
- [ ] Deployment approved
- [ ] Infrastructure deployed
- [ ] Containers healthy
- [ ] Application healthy
- [ ] Monitoring healthy
- [ ] Logs available
- [ ] Alerts tested
- [ ] Deployment documented
