# Troubleshooting Guide

## 1. Purpose

This document contains common troubleshooting procedures for the Terraform infrastructure platform.

## 2. General Troubleshooting Process

Always follow:

    Identify
       ↓
    Reproduce
       ↓
    Inspect Logs
       ↓
    Inspect Configuration
       ↓
    Identify Root Cause
       ↓
    Apply Minimal Fix
       ↓
    Validate
       ↓
    Document

Do not randomly modify infrastructure.

## 3. Terraform Initialization Failure

Run:

    terraform init

If provider errors occur:

    terraform providers

Check:

- Terraform version
- Provider version
- Network connectivity
- Provider configuration

## 4. Terraform Validation Failure

Run:

    terraform validate

Then:

    terraform fmt -recursive

Check:

- Syntax
- Variable definitions
- Module paths
- Provider configuration
- Resource references

## 5. Terraform Plan Failure

Run:

    terraform plan

Check:

- Missing variables
- Invalid provider configuration
- Resource dependencies
- State inconsistencies
- Credentials
- Network connectivity

## 6. Terraform State Problems

Inspect:

    terraform state list

Inspect a resource:

    terraform state show <resource>

Do not modify Terraform state casually.

State operations require careful review.

## 7. Docker Container Not Starting

Check:

    docker ps -a
    docker logs <container>
    docker inspect <container>

Check:

- Image
- Environment variables
- Ports
- Volumes
- Networks
- Permissions
- Dependencies

## 8. Docker Port Conflict

Check:

    docker ps
    sudo ss -lntp

Change host port if required.

Do not expose unnecessary ports.

## 9. Docker Network Problems

List networks:

    docker network ls

Inspect:

    docker network inspect <network>

Verify that dependent containers are attached to the same network.

## 10. Docker Volume Problems

List:

    docker volume ls

Inspect:

    docker volume inspect <volume>

Check:

- Permissions
- Mount path
- Existing data
- Container configuration

Never delete a production volume without explicit approval.

## 11. Jenkins Problems

Check:

    docker logs jenkins

Verify:

- Jenkins container
- Java runtime
- Plugins
- Git access
- Credentials
- Workspace
- Docker access

## 12. Jenkins Cannot Access GitHub

Check:

- SSH key
- GitHub credentials
- Repository URL
- Branch
- Network connectivity

Test Git:

    git ls-remote <repository-url>

## 13. Jenkins Cannot Access Docker

Check Docker socket:

    ls -l /var/run/docker.sock

Check:

    docker ps

Verify Jenkins has appropriate access.

Do not grant excessive host privileges without understanding the security implications.

## 14. Prometheus Problems

Check:

    docker logs prometheus

Verify configuration and targets.

Expected target states:

- UP
- DOWN

Investigate DOWN targets.

## 15. Grafana Problems

Check:

    docker logs grafana

Verify:

- Prometheus datasource
- Loki datasource
- Credentials
- Network
- Dashboard configuration

## 16. Loki Problems

Check:

    docker logs loki

Verify:

- Configuration
- Storage
- Network
- Client connectivity

## 17. OpenTelemetry Problems

Check:

    docker logs otel-collector

Verify:

- gRPC port 4317
- HTTP port 4318
- Exporters
- Receivers
- Pipelines
- Network connectivity

## 18. Redis Problems

Check:

    docker logs redis

Test connectivity:

    redis-cli ping

Expected:

    PONG

## 19. RabbitMQ Problems

Check:

    docker logs rabbitmq

Verify:

- Port 5672
- Management port 15672
- User credentials
- Queue configuration
- Network connectivity

## 20. Vault Problems

Check:

    docker logs vault

Verify:

- Vault status
- Initialization
- Seal status
- Storage
- Network
- TLS

Never expose Vault unnecessarily.

## 21. Registry Problems

Check:

    docker logs registry

Test:

    curl http://localhost:5000/v2/

Expected response should indicate registry availability.

## 22. Kubernetes Problems

Check:

    kubectl get nodes
    kubectl get pods -A
    kubectl get services -A

Check pod:

    kubectl describe pod <pod>

Check logs:

    kubectl logs <pod>

Check events:

    kubectl get events -A --sort-by=.lastTimestamp

## 23. Kubernetes CrashLoopBackOff

Check:

    kubectl logs <pod>
    kubectl logs <pod> --previous
    kubectl describe pod <pod>

Investigate:

- Environment variables
- Secrets
- ConfigMaps
- Probes
- Resource limits
- Application startup
- Network connectivity

## 24. Kubernetes ImagePullBackOff

Check:

- Registry availability
- Image name
- Image tag
- ImagePullSecrets
- Authentication

Verify image:

    docker pull <image>

## 25. Application Cannot Connect to Database

Check:

- Hostname
- Port
- Credentials
- Network
- Database availability
- Firewall
- Connection string

Do not expose database ports publicly just to solve connectivity issues.

## 26. Application Cannot Connect to Redis

Check:

- Redis container
- Network
- Redis hostname
- Port 6379
- Credentials if enabled

## 27. Application Cannot Connect to RabbitMQ

Check:

- RabbitMQ container
- Network
- Hostname
- Port 5672
- Credentials
- Virtual host
- Queue configuration

## 28. Application Cannot Connect to Vault

Check:

- Vault status
- URL
- Port 8200
- Authentication
- Token
- TLS
- Network

## 29. CI/CD Failure

Follow:

    Jenkins
       ↓
    Checkout
       ↓
    Build
       ↓
    Test
       ↓
    Docker
       ↓
    Registry
       ↓
    Deployment

Identify the first failing stage.

Do not troubleshoot later stages before resolving the first failure.

## 30. Monitoring Troubleshooting

If metrics are missing:

1. Check application metrics endpoint.
2. Check Prometheus target.
3. Check network.
4. Check Prometheus configuration.
5. Check Grafana datasource.

If logs are missing:

1. Check application logging.
2. Check OpenTelemetry.
3. Check Loki.
4. Check Grafana datasource.

## 31. Common Terraform/Docker Issue

If Terraform reports:

    Error response from daemon: Conflict

Check:

    docker ps -a

A previous container may already exist.

Do not immediately delete it.

Determine whether it is managed by Terraform.

## 32. Common Provider Issue

If Terraform reports provider errors:

    terraform providers

Check:

- required_providers
- provider version
- Terraform version
- lock file

Do not delete `.terraform.lock.hcl` without understanding why.

## 33. Troubleshooting Rule for Claude

When troubleshooting:

1. Do not guess.
2. Collect evidence.
3. Inspect logs.
4. Inspect configuration.
5. Identify root cause.
6. Explain the root cause.
7. Apply the smallest fix.
8. Validate.
9. Document recurring problems.

Never hide errors just to make the deployment appear successful.
