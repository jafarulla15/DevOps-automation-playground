variable "network_name" {
  description = "Docker network shared with application containers; containers must be attached to this network for Nginx to resolve them by name"
  type        = string
}

variable "container_name" {
  description = "Nginx Docker container name"
  type        = string
  default     = "nginx"
}

variable "image" {
  description = "Nginx Docker image"
  type        = string
  default     = "nginx:1.27-alpine"
}

variable "http_port" {
  description = "Host port for HTTP"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "Host port for HTTPS"
  type        = number
  default     = 443
}

variable "certs_dir" {
  description = "Host directory containing TLS cert/key files, bind-mounted read-only into the container at /etc/nginx/certs. Required if any application has enable_tls = true."
  type        = string
  default     = null
}

variable "applications" {
  description = "Map of applications to reverse-proxy, keyed by a unique name. Each upstream_container must be attached to var.network_name so Nginx can resolve it by Docker DNS."

  type = map(object({
    server_name              = string
    upstream_container       = string
    upstream_port            = number
    client_max_body_size     = optional(string, "10m")
    enable_tls               = optional(bool, false)
    ssl_certificate_file     = optional(string) # filename under var.certs_dir
    ssl_certificate_key_file = optional(string) # filename under var.certs_dir
  }))

  default = {}

  validation {
    condition = alltrue([
      for k, a in var.applications :
      !a.enable_tls || (a.ssl_certificate_file != null && a.ssl_certificate_key_file != null)
    ])
    error_message = "When enable_tls is true, both ssl_certificate_file and ssl_certificate_key_file must be set."
  }

  validation {
    condition     = !anytrue([for k, a in var.applications : a.enable_tls]) || var.certs_dir != null
    error_message = "var.certs_dir must be set when any application has enable_tls = true."
  }
}
