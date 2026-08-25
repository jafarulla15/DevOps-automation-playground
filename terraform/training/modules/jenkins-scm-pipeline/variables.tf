variable "pipelines" {
  description = "Map of Jenkins pipeline jobs to create, keyed by a unique job name. Each pipeline reads its actual build/test/deploy steps from a Jenkinsfile in its own GitHub repository."

  type = map(object({
    application_name   = string
    git_repository_url = string
    git_branch         = optional(string, "main")
    jenkinsfile_path   = optional(string, "Jenkinsfile")
    poll_schedule      = optional(string, "H/5 * * * *")
    description        = optional(string)

    # Provide EITHER git_credentials_id (reuse an existing Jenkins credential)
    # OR git_username + git_token (this module creates a new credential).
    git_credentials_id = optional(string)
    git_username       = optional(string)
    git_token          = optional(string)
  }))

  validation {
    condition = alltrue([
      for k, p in var.pipelines :
      p.git_credentials_id != null || (p.git_username != null && p.git_token != null)
    ])
    error_message = "Each pipeline entry must set either git_credentials_id, or both git_username and git_token."
  }
}
