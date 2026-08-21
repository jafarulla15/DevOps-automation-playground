variable "network_name" {
  description = "Docker network name"
  type        = string
  default     = "monitoring"
}

variable "port" {
  description = "Docker Registry host port"
  type        = number
  default     = 5000
}

variable "image" {
  description = "Docker Registry image"
  type        = string
  default     = "registry:3"
}
