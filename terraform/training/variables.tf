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
