locals {
  image_names = {
    for key, p in var.pipelines :
    key => p.docker_registry != "" ? "${p.docker_registry}/${p.container_name}" : p.container_name
  }
}

resource "jenkins_job" "this" {
  for_each = var.pipelines

  name = each.key

  template = templatefile("${path.module}/templates/pipeline-script.xml.tpl", {
    description = "Terraform-managed pipeline for ${each.value.application_name}"

    script = templatefile("${path.module}/templates/app.Jenkinsfile.tpl", {
      application_name   = each.value.application_name
      git_repository_url = each.value.git_repository_url
      git_branch         = each.value.git_branch
      git_credentials_id = each.value.git_credentials_id
      image_name         = local.image_names[each.key]
      container_name     = each.value.container_name
      container_port     = each.value.container_port
      host_port          = each.value.host_port
      docker_network     = each.value.docker_network
      poll_schedule      = each.value.poll_schedule
    })
  })
}
