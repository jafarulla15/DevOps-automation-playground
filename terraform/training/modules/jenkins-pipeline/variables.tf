variable "pipelines" {
  description = "Map of application pipelines to create, keyed by a unique Jenkins job name. To onboard a new application, add an entry here - the app's own Dockerfile does all the build work, so this works for any language/stack with no new files needed."

  type = map(object({
    application_name   = string
    git_repository_url = string
    git_branch         = optional(string, "main")
    git_credentials_id = string # must already exist as a Jenkins credential

    docker_registry = optional(string, "") # e.g. "192.168.238.50:5000"; empty means use container_name as the image name directly
    container_name  = string
    container_port  = number
    host_port       = optional(number) # if set, published on the host in addition to docker_network
    docker_network  = optional(string) # Docker network to attach the deployed container to

    poll_schedule = optional(string) # e.g. "H/5 * * * *"; if set, adds an unconditional periodic rebuild trigger
  }))
}
