variable "network_name" {
  description = "Docker network name"
  type        = string
  default     = "monitoring"
}

variable "grpc_port" {
  description = "OpenTelemetry Collector OTLP gRPC host port"
  type        = number
  default     = 4317
}

variable "http_port" {
  description = "OpenTelemetry Collector OTLP HTTP host port"
  type        = number
  default     = 4318
}

variable "config_file" {
  description = "Path to OpenTelemetry Collector configuration file"
  type        = string
}

variable "image" {
  description = "OpenTelemetry Collector Docker image"
  type        = string
  default     = "otel/opentelemetry-collector:latest"
}
