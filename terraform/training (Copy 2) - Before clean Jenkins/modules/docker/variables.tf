variable "server_ip" {
  description = "IP address of the Ubuntu server"
  type        = string
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
}
