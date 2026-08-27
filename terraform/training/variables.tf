variable "server_name" {
  description = "Training server hostname"
  type        = string
  default     = "earn-training"
}

variable "ssh_user" {
  description = "Linux user used for remote configuration"
  type        = string
}

variable "server_ip" {
  description = "IP address of the existing Linux VM"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
}

# SQL -Server

variable "sqlserver_sa_password" {
  description = "SQL Server SA password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.sqlserver_sa_password) >= 8
    error_message = "SQL Server SA password must be at least 8 characters."
  }
}

# Jenkins

variable "jenkins_admin_password" {
  description = "Jenkins administrator password"
  type        = string
  sensitive   = true
}

# Grafana

variable "grafana_admin_user" {
  description = "Grafana administrator username"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana administrator password"
  type        = string
  sensitive   = true
}


# Others

variable "network_name" {
  type    = string
  default = "monitoring"
}

variable "loki_port" {
  type    = number
  default = 3100
}

variable "otel_grpc_port" {
  type    = number
  default = 4317
}

variable "otel_http_port" {
  type    = number
  default = 4318
}

variable "redis_port" {
  type    = number
  default = 6379
}

variable "rabbitmq_port" {
  type    = number
  default = 5672
}

variable "rabbitmq_management_port" {
  type    = number
  default = 15672
}

variable "alertmanager_port" {
  type    = number
  default = 9093
}

variable "vault_port" {
  type    = number
  default = 8200
}

variable "registry_port" {
  type    = number
  default = 5000
}

variable "vault_root_token" {
  description = "HashiCorp Vault root token"
  type        = string
  sensitive   = true
}

variable "rabbitmq_password" {
  description = "RabbitMQ password"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "Redis password"
  type        = string
  sensitive   = true
}

variable "rabbitmq_username" {
  description = "RabbitMQ username"
  type        = string
}

# Jenkins Pipeline

variable "jenkins_url" {
  description = "Jenkins URL"
  type        = string
}

variable "jenkins_username" {
  description = "Jenkins administrator username"
  type        = string
  sensitive   = true
}

variable "jenkins_password" {
  description = "Jenkins administrator password"
  type        = string
  sensitive   = true
}
