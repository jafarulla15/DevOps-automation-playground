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


