variable "container_name" {
  description = "Jenkins Docker container name"
  type        = string
  default     = "jenkins"
}

variable "image" {
  description = "Jenkins Docker image"
  type        = string
  default     = "jenkins-custom:lts"
}

variable "host_port" {
  description = "Jenkins web UI host port"
  type        = number
  default     = 8080
}

variable "container_port" {
  description = "Jenkins web UI container port"
  type        = number
  default     = 8080
}

variable "agent_host_port" {
  description = "Jenkins agent host port"
  type        = number
  default     = 50000
}

variable "agent_container_port" {
  description = "Jenkins agent container port"
  type        = number
  default     = 50000
}

variable "volume_name" {
  description = "Persistent Jenkins Docker volume"
  type        = string
  default     = "jenkins_home"
}

variable "restart_policy" {
  description = "Docker restart policy"
  type        = string
  default     = "unless-stopped"
}

variable "timezone" {
  description = "Jenkins timezone"
  type        = string
  default     = "Asia/Dhaka"
}

variable "admin_user" {
  description = "Jenkins administrator username"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Jenkins administrator password"
  type        = string
  sensitive   = true
}

variable "jenkins_host" {
  description = "Hostname or IP address used by Jenkins"
  type        = string
  default     = "localhost"
}
