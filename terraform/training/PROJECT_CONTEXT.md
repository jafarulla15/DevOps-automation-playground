# Project Context

## 1. Project Name

Terraform Infrastructure Platform

## 2. Project Goal

Build an automated DevOps infrastructure platform using Terraform.

The platform should allow infrastructure and application deployment to be repeatable and maintainable.

## 3. Primary Objective

Automate as much infrastructure work as possible using Terraform.

Terraform should be responsible for provisioning and configuring infrastructure resources wherever practical.

## 4. Current Infrastructure Goals

The project is intended to support:

- Application hosting
- Docker containers
- CI/CD
- Kubernetes
- Monitoring
- Logging
- Distributed tracing
- Messaging
- Caching
- Secret management
- Container registry
- Authentication

## 5. Application Technology

Frontend:

- Angular

Backend:

- .NET 8
- REST APIs
- Microservices

Database:

- SQL Server

Additional technologies:

- Redis
- RabbitMQ
- Keycloak
- HashiCorp Vault

## 6. Infrastructure Technology

Core:

- Ubuntu Linux
- Terraform
- Docker
- Kubernetes

CI/CD:

- Jenkins
- GitHub

Monitoring:

- Prometheus
- Grafana
- Alertmanager

Logging:

- Loki

Observability:

- OpenTelemetry

Registry:

- Docker Registry

Secrets:

- HashiCorp Vault

## 7. Development Philosophy

The project follows:

- Infrastructure as Code
- Automation
- Modularity
- Security by design
- Observability
- Reproducibility
- Documentation
- Git-based change management

## 8. Environment Strategy

Supported environments:

- Development
- Staging
- Production

Development should prioritize rapid iteration.

Staging should be as close to production as practical.

Production should prioritize:

- Security
- Reliability
- Availability
- Backup
- Monitoring
- Controlled deployments

## 9. Terraform Strategy

Terraform modules should be reusable.

Environment configuration should consume modules.

Example:

    Environment
        |
        +--> Docker Module
        |
        +--> Jenkins Module
        |
        +--> Monitoring Modules
        |
        +--> Messaging Modules
        |
        +--> Security Modules

## 10. CI/CD Strategy

Expected flow:

    GitHub
       ↓
    Jenkins
       ↓
    Build
       ↓
    Test
       ↓
    Docker Image
       ↓
    Registry
       ↓
    Deployment
       ↓
    Health Check

## 11. Security Strategy

Secrets should be managed using HashiCorp Vault.

Security requirements include:

- No secrets in Git
- No secrets in Terraform source
- Restricted network access
- Least privilege
- Secure credentials
- TLS where required
- Regular dependency updates

## 12. Observability Strategy

Every important application and infrastructure component should be observable.

Metrics:

Prometheus

Visualization:

Grafana

Logs:

Loki

Telemetry:

OpenTelemetry

Alerts:

Alertmanager

## 13. AI Engineering Strategy

Claude Code is used as an AI-assisted DevOps engineering tool.

Claude should help with:

- Architecture analysis
- Terraform implementation
- Module generation
- Terraform review
- Security review
- Troubleshooting
- Documentation
- CI/CD
- Docker
- Kubernetes

Human approval is required for destructive infrastructure operations.

## 14. Current Development Priority

Prioritize work in this order:

1. Terraform foundation
2. Docker infrastructure
3. Networking
4. Jenkins
5. Application deployment
6. Registry
7. Database
8. Redis
9. RabbitMQ
10. Vault
11. Monitoring
12. Logging
13. OpenTelemetry
14. Alerting
15. Kubernetes
16. Security hardening
17. CI/CD optimization

## 15. Expected Result

The final platform should allow a developer to:

1. Push application code to GitHub.
2. Trigger Jenkins.
3. Build the application.
4. Run tests.
5. Build Docker images.
6. Push images to the registry.
7. Deploy the application.
8. Monitor the application.
9. Collect logs.
10. Receive alerts.
11. Manage secrets securely.
