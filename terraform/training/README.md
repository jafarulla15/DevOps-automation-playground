# Terraform Infrastructure Platform

Infrastructure-as-Code project for deploying and managing application infrastructure using Terraform.

## 1. Overview

This repository contains Terraform modules and environment configurations for deploying a complete DevOps platform.

The platform includes:

- Docker
- Kubernetes
- Jenkins
- Prometheus
- Grafana
- Loki
- OpenTelemetry
- Alertmanager
- Redis
- RabbitMQ
- HashiCorp Vault
- Docker Registry
- Application infrastructure

The objective is to automate infrastructure provisioning and deployment as much as possible.

## 2. High-Level Architecture

    GitHub
       |
       v
    Jenkins
       |
       v
    Build & Test
       |
       v
    Docker Build
       |
       v
    Docker Registry
       |
       v
    Deployment
       |
       +----------------+
       |                |
       v                v
    Application      Infrastructure
       |                |
       +-------+--------+
               |
       +-------+-------+
       |       |       |
      Redis RabbitMQ SQL Server

Observability:

    Applications
         |
         v
    OpenTelemetry
         |
         +--------+
         |        |
         v        v
      Metrics    Logs
         |        |
         v        v
    Prometheus   Loki
         |        |
         +---+----+
             |
             v
          Grafana
             |
             v
        Alertmanager

Security:

    Application
         |
         +----------+
         |          |
         v          v
      Keycloak    Vault
         |          |
         v          v
    Identity      Secrets

See `ARCHITECTURE.md` for details.

## 3. Repository Structure

    terraform-infrastructure/
    ├── CLAUDE.md
    ├── README.md
    ├── ARCHITECTURE.md
    ├── PROJECT_CONTEXT.md
    ├── DEPLOYMENT.md
    ├── SECURITY.md
    ├── TROUBLESHOOTING.md
    ├── .claude/
    ├── environments/
    │   ├── dev/
    │   ├── staging/
    │   └── prod/
    ├── modules/
    │   ├── docker/
    │   ├── jenkins/
    │   ├── prometheus/
    │   ├── grafana/
    │   ├── loki/
    │   ├── opentelemetry/
    │   ├── redis/
    │   ├── rabbitmq/
    │   ├── vault/
    │   ├── registry/
    │   └── alertmanager/
    └── scripts/

## 4. Prerequisites

Install:

- Terraform
- Docker
- Git
- Linux / Ubuntu
- kubectl
- Helm where required

Optional:

- AWS CLI
- Azure CLI
- GitHub CLI

## 5. Terraform Workflow

Initialize:

    terraform init

Format:

    terraform fmt -recursive

Validate:

    terraform validate

Create plan:

    terraform plan

Apply:

    terraform apply

Destroy:

    terraform destroy

Production destruction requires explicit approval.

## 6. Module Standards

Every reusable module should preferably contain:

    main.tf
    variables.tf
    outputs.tf
    versions.tf
    README.md

Modules should be:

- Reusable
- Configurable
- Documented
- Secure
- Environment independent

## 7. Environments

Infrastructure is separated into:

- dev
- staging
- prod

Environment-specific configuration should not be hardcoded into reusable modules.

## 8. Security

Never commit:

- Passwords
- API keys
- Tokens
- Private keys
- Certificates
- Terraform state
- Environment secrets

See `SECURITY.md`.

## 9. CI/CD

Expected pipeline:

    GitHub
       ↓
    Jenkins
       ↓
    Restore Dependencies
       ↓
    Build
       ↓
    Test
       ↓
    Docker Build
       ↓
    Security Scan
       ↓
    Docker Registry
       ↓
    Deployment
       ↓
    Health Check

## 10. Observability

The platform uses:

- Prometheus
- Grafana
- Loki
- OpenTelemetry
- Alertmanager

## 11. Infrastructure Services

| Service | Purpose |
|---|---|
| Jenkins | CI/CD |
| Registry | Docker image storage |
| Prometheus | Metrics |
| Grafana | Visualization |
| Loki | Logs |
| OpenTelemetry | Telemetry |
| Alertmanager | Alerts |
| Redis | Cache |
| RabbitMQ | Messaging |
| Vault | Secrets |
| Keycloak | Identity |
| SQL Server | Database |

## 12. Development Rules

Before committing Terraform:

    terraform fmt -recursive
    terraform validate
    terraform plan

Review:

    git diff

## 13. AI-Assisted Development

This repository is designed to work with Claude Code.

Primary AI instructions:

`CLAUDE.md`

AI Skills:

`.claude/skills/`

AI agents:

`.claude/agents/`

Claude must follow project security and change-management rules.

## 14. Project Status

Update this section as infrastructure components are completed.

| Component | Status |
|---|---|
| Terraform Base | Planned |
| Docker | Planned |
| Jenkins | Planned |
| Prometheus | Planned |
| Grafana | Planned |
| Loki | Planned |
| OpenTelemetry | Planned |
| Redis | Planned |
| RabbitMQ | Planned |
| Vault | Planned |
| Registry | Planned |
| Alertmanager | Planned |
| Kubernetes | Planned |
| CI/CD | Planned |
