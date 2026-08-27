variable "container_name" {
  description = "Prometheus container name"
  type        = string
  default     = "prometheus"
}

variable "image" {
  description = "Prometheus Docker image"
  type        = string
  default     = "prom/prometheus:latest"
}

variable "port" {
  description = "Prometheus host port"
  type        = number
  default     = 9090
}

variable "network_name" {
  description = "Docker network name"
  type        = string
  default     = "monitoring"
}

variable "config_file" {
  description = "Path to Prometheus configuration file"
  type        = string
  default     = "./prometheus/prometheus.yml"
}

variable "data_volume" {
  description = "Prometheus data volume"
  type        = string
  default     = "prometheus_data"
}
