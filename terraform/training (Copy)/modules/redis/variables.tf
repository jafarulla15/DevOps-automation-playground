variable "network_name" {
  description = "Docker network name"
  type        = string
  default     = "monitoring"
}

variable "port" {
  description = "Redis host port"
  type        = number
  default     = 6379
}

variable "image" {
  description = "Redis Docker image"
  type        = string
  default     = "redis:7-alpine"
}
