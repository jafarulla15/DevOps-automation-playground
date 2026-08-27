variable "container_name" {
  description = "SQL Server Docker container name"
  type        = string
  default     = "sqlserver-express"
}

variable "image" {
  description = "SQL Server Docker image"
  type        = string
  default     = "mcr.microsoft.com/mssql/server:2022-latest"
}

variable "host_port" {
  description = "Host port for SQL Server"
  type        = number
  default     = 1433
}

variable "container_port" {
  description = "SQL Server container port"
  type        = number
  default     = 1433
}

variable "sa_password" {
  description = "SQL Server SA password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.sa_password) >= 8
    error_message = "SQL Server SA password must be at least 8 characters."
  }
}

variable "edition" {
  description = "SQL Server edition"
  type        = string
  default     = "Express"

  validation {
    condition = contains(
      ["Developer", "Express", "Standard", "Enterprise"],
      var.edition
    )

    error_message = "Edition must be Developer, Express, Standard, or Enterprise."
  }
}

variable "volume_name" {
  description = "Docker volume used for SQL Server persistence"
  type        = string
  default     = "sqlserver_data"
}

variable "restart_policy" {
  description = "Docker container restart policy"
  type        = string
  default     = "unless-stopped"
}
