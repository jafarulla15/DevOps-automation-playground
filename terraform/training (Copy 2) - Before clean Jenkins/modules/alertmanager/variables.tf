variable "network_name" {
  description = "Docker network name"
  type        = string
  default     = "monitoring"
}

variable "port" {
  description = "Alertmanager host port"
  type        = number
  default     = 9093
}

variable "config_file" {
  description = "Path to Alertmanager configuration file"
  type        = string
}

variable "image" {
  description = "Prometheus Alertmanager Docker image"
  type        = string
  default     = "prom/alertmanager:latest"
}
