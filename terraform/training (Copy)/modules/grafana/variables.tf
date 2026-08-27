variable "container_name" {
  description = "Grafana container name"
  type        = string
  default     = "grafana"
}

variable "image" {
  description = "Grafana Docker image"
  type        = string
  default     = "grafana/grafana:latest"
}

variable "port" {
  description = "Grafana host port"
  type        = number
  default     = 3000
}

variable "network_name" {
  description = "Docker network name"
  type        = string
  default     = "monitoring"
}

variable "data_volume" {
  description = "Grafana data volume"
  type        = string
  default     = "grafana_data"
}

variable "admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}
