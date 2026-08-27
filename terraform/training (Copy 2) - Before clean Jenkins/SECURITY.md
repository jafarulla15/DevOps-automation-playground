# Security Policy

## 1. Purpose

This document defines security requirements for the infrastructure project.

Security must be considered during:

- Design
- Development
- Deployment
- Operations
- Troubleshooting

## 2. Secrets

Never hardcode secrets.

Forbidden:

    password = "MyPassword123"
    api_key = "secret-key"
    token = "xxxxx"

Secrets should be stored using HashiCorp Vault or another approved secret manager.

## 3. Sensitive Files

Never commit:

    .env
    .env.*
    *.pem
    *.key
    *.pfx
    *.p12
    credentials.json
    terraform.tfstate
    terraform.tfstate.backup
    secrets/

## 4. Git Security

Before commit:

    git status
    git diff

Check for:

- Passwords
- API keys
- Tokens
- Private keys
- Connection strings
- Cloud credentials

## 5. Terraform State

Terraform state can contain sensitive information.

Do not commit state files.

Preferred production approach:

- Remote backend
- Encryption
- Access control
- State locking
- Backup

## 6. Docker Security

Containers should:

- Use trusted images
- Prefer pinned versions
- Avoid unnecessary privileges
- Avoid privileged mode
- Avoid host networking unless required
- Expose only required ports
- Use non-root users where practical
- Use health checks

## 7. Image Security

Container images should be scanned for vulnerabilities.

Preferred pipeline:

    Build
      ↓
    Scan
      ↓
    Approve
      ↓
    Push
      ↓
    Deploy

Do not deploy known critical vulnerabilities without documented approval.

## 8. Network Security

Follow least privilege.

Only expose required ports.

Internal services should preferably communicate through private Docker or Kubernetes networks.

Examples of services that should normally remain internal:

- Redis
- RabbitMQ
- SQL Server
- Vault
- Loki
- OpenTelemetry
- Prometheus

## 9. SSH Security

Use SSH keys instead of passwords where possible.

Private keys must never be committed.

Never place private key contents in Terraform source.

## 10. Jenkins Security

Jenkins must use:

- Secure credentials
- Role-based access
- Restricted agents
- Protected secrets
- HTTPS where applicable
- GitHub webhook security
- Plugin updates

Never expose Jenkins administrative credentials in source code.

## 11. GitHub Security

Use:

- SSH keys or secure tokens
- Branch protection
- Pull requests
- Required reviews
- Secret scanning
- Dependency scanning

Do not store infrastructure credentials in GitHub repository files.

## 12. Vault

HashiCorp Vault should be the preferred centralized secret-management platform.

Vault should manage:

- Database credentials
- API credentials
- Application secrets
- Service credentials
- Tokens

## 13. Kubernetes Security

Use:

- Namespaces
- RBAC
- Network policies where appropriate
- Secrets
- Resource limits
- Security contexts
- Non-root containers
- Restricted service accounts

Avoid:

    privileged: true

unless explicitly required.

## 14. IAM

Use least privilege.

Avoid administrative permissions for applications.

Separate:

- Infrastructure administration
- CI/CD
- Application runtime
- Monitoring
- Development

## 15. TLS

Use TLS for sensitive communication.

Examples:

- GitHub
- Jenkins
- APIs
- Vault
- Registry
- Grafana
- Kubernetes ingress

## 16. Logging Security

Do not log:

- Passwords
- Tokens
- Authorization headers
- Private keys
- Sensitive personal information

## 17. Monitoring Security

Monitoring systems should not expose sensitive information publicly.

Protect:

- Grafana
- Prometheus
- Alertmanager
- Loki
- Jenkins
- Vault

## 18. Dependency Security

Regularly update:

- Terraform providers
- Docker images
- Jenkins plugins
- Kubernetes images
- Application dependencies

Test updates before production deployment.

## 19. Security Review

Before major infrastructure changes:

1. Identify attack surface.
2. Review exposed ports.
3. Review credentials.
4. Review permissions.
5. Review container privileges.
6. Review network access.
7. Review data persistence.
8. Review logs.
9. Review secrets.
10. Review rollback.

## 20. Security Severity

### CRITICAL

Immediate action required.

Examples:

- Exposed credentials
- Public database
- Private key committed
- Critical authentication bypass

### HIGH

Action required before production.

Examples:

- Excessive permissions
- Unprotected administrative endpoint
- Critical vulnerable container

### MEDIUM

Should be addressed.

### LOW

Improvement opportunity.

## 21. Security Rule for Claude

Claude must never:

- Expose secrets
- Print secret contents
- Commit credentials
- Execute destructive security changes without approval
- Disable security controls just to make deployment work

If a secure solution is difficult, explain the problem and propose alternatives.
