variable "job_name" {
  description = "Jenkins job name"
  type        = string
}

variable "application_name" {
  description = "Application name"
  type        = string
}

variable "git_repository_url" {
  description = "Git repository URL"
  type        = string
}

variable "git_branch" {
  description = "Git branch"
  type        = string
  default     = "main"
}

variable "git_credentials_id" {
  description = "Jenkins credential ID"
  type        = string
}

variable "git_username" {
  description = "Git username"
  type        = string
  sensitive   = true
}

variable "git_token" {
  description = "Git personal access token"
  type        = string
  sensitive   = true
}

variable "docker_registry" {
  description = "Docker registry"
  type        = string
}

variable "application_port" {
  description = "Application container port"
  type        = number
}

variable "host_port" {
  description = "Host port"
  type        = number
}
