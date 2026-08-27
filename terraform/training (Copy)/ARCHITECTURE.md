# Infrastructure Architecture

## 1. Purpose

This document describes the architecture of the Terraform-managed infrastructure platform.

The architecture is designed to provide:

- Infrastructure automation
- Application deployment
- CI/CD
- Containerization
- Observability
- Centralized logging
- Secret management
- Messaging
- Caching
- Monitoring
- Alerting

## 2. High-Level Architecture

    +----------------------+
    |       Developer      |
    +----------+-----------+
               |
               v
    +----------------------+
    |       GitHub         |
    +----------+-----------+
               |
               v
    +----------------------+
    |       Jenkins        |
    |       CI/CD          |
    +----------+-----------+
               |
       +-------+-------+
       |               |
       v               v
    Build/Test       Docker Build
                       |
                       v
                +--------------+
                |   Registry   |
                +------+-------+
                       |
                       v
                +--------------+
                | Deployment   |
                +------+-------+
                       |
             +---------+---------+
             |                   |
             v                   v
       Application          Infrastructure

## 3. Application Architecture

    Angular
       |
       v
    API Gateway / Reverse Proxy
       |
       v
    .NET 8 REST APIs
       |
       +--------+---------+---------+
       |        |         |         |
       v        v         v         v
     Redis   RabbitMQ   SQL Server  Vault

## 4. CI/CD Architecture

    Developer
        |
        v
    GitHub Repository
        |
        v
    Jenkins
        |
        +--> Checkout
        |
        +--> Restore
        |
        +--> Build
        |
        +--> Unit Test
        |
        +--> Security Scan
        |
        +--> Docker Build
        |
        +--> Docker Push
        |
        +--> Deploy
        |
        +--> Health Check

## 5. Container Architecture

Related services should use appropriate Docker networks.

Example:

    monitoring
        |
        +-- Prometheus
        +-- Grafana
        +-- Loki
        +-- Alertmanager
        +-- OpenTelemetry

Application network:

    application
        |
        +-- API
        +-- Redis
        +-- RabbitMQ
        +-- SQL Server
        +-- Vault

Use separate networks when isolation is required.

## 6. Monitoring Architecture

    Application
        |
        +------ Metrics ------+
        |                     |
        |                     v
        |                Prometheus
        |                     |
        |                     v
        |                  Grafana
        |
        +------ Logs --------+
        |                     |
        |                     v
        |                    Loki
        |                     |
        |                     v
        |                  Grafana
        |
        +--- Telemetry ------+
                              |
                              v
                       OpenTelemetry

Prometheus alerts:

    Prometheus
         |
         v
    Alertmanager
         |
         +--> Email
         +--> Slack
         +--> Other notification channels

## 7. Logging Architecture

    Application
         |
         v
    OpenTelemetry / Log Collector
         |
         v
        Loki
         |
         v
      Grafana

## 8. Metrics Architecture

    Application
         |
         v
    Metrics Endpoint
         |
         v
    Prometheus
         |
         v
    Grafana

Infrastructure metrics should include:

- CPU
- Memory
- Disk
- Network
- Container health
- Kubernetes health
- Application health

## 9. Security Architecture

    Application
         |
         +----------+
         |          |
         v          v
      Keycloak    Vault
         |          |
         v          v
    Identity      Secrets

Secrets must not be stored directly in Terraform source code.

## 10. Data Architecture

### SQL Server

Used for relational application data.

Requirements:

- Persistent storage
- Backup strategy
- Restricted network access
- Credentials managed securely

### Redis

Used for:

- Caching
- Temporary state
- Distributed locks where applicable

### RabbitMQ

Used for:

- Asynchronous messaging
- Event processing
- Service communication

## 11. Terraform Architecture

    Root Configuration
          |
          +----------------+
          |                |
          v                v
     Environments       Modules
          |                |
          |        +-------+-------+
          |        |       |       |
          |        v       v       v
          |      Jenkins Redis  RabbitMQ
          |
          +--> Dev
          +--> Staging
          +--> Production

## 12. Module Architecture

Each module should have a single clear responsibility.

    modules/
    ├── docker/
    ├── jenkins/
    ├── prometheus/
    ├── grafana/
    ├── loki/
    ├── opentelemetry/
    ├── redis/
    ├── rabbitmq/
    ├── vault/
    ├── registry/
    └── alertmanager/

Modules should avoid unnecessary coupling.

## 13. Environment Architecture

    environments/
    ├── dev/
    ├── staging/
    └── prod/

Environment differences should be handled through:

- variables
- tfvars
- module inputs
- separate state
- environment-specific configuration

## 14. State Management

Terraform state must be protected.

Production state should preferably use:

- Remote backend
- State locking
- Encryption
- Restricted access
- Backup

Never commit Terraform state to Git.

## 15. Network Architecture

Network design should follow least-privilege principles.

Only required ports should be exposed.

| Service | Port |
|---|---:|
| Jenkins | 8080 |
| Grafana | 3000 |
| Prometheus | 9090 |
| Alertmanager | 9093 |
| Loki | 3100 |
| OpenTelemetry gRPC | 4317 |
| OpenTelemetry HTTP | 4318 |
| Redis | 6379 |
| RabbitMQ | 5672 |
| RabbitMQ Management | 15672 |
| Vault | 8200 |
| Registry | 5000 |

Do not expose internal service ports publicly unless required.

## 16. Architecture Principles

1. Infrastructure as Code
2. Automation first
3. Least privilege
4. Modular design
5. Immutable deployment where possible
6. Environment separation
7. Centralized observability
8. Secure secret management
9. Reproducibility
10. Disaster recovery

## 17. Architecture Change Process

Before changing architecture:

1. Describe current behavior.
2. Describe desired behavior.
3. Identify affected modules.
4. Identify dependencies.
5. Identify migration requirements.
6. Identify downtime.
7. Identify rollback strategy.
8. Obtain approval.
9. Implement.
10. Update this document.
