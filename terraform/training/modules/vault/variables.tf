variable "network_name" {
  description = "Docker network name"
  type        = string
  default     = "monitoring"
}

variable "port" {
  description = "HashiCorp Vault host port"
  type        = number
  default     = 8200
}

variable "image" {
  description = "HashiCorp Vault Docker image"
  type        = string
  default     = "hashicorp/vault:latest"
}
