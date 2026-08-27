variable "network_name" {
  description = "Docker network name"
  type        = string
  default     = "monitoring"
}

variable "port" {
  description = "Loki host port"
  type        = number
  default     = 3100
}

variable "config_file" {
  description = "Path to Loki configuration file"
  type        = string
}

variable "image" {
  description = "Loki Docker image"
  type        = string
  default     = "grafana/loki:3.5.0"
}
