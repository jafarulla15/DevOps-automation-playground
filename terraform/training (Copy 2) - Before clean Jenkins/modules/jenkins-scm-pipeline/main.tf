locals {
  # Effective credential id per pipeline: caller-supplied, or one this module creates.
  credential_ids = {
    for key, p in var.pipelines :
    key => coalesce(p.git_credentials_id, "${key}-github-credentials")
  }
}

resource "jenkins_credential" "git" {
  for_each = { for key, p in var.pipelines : key => p if p.git_credentials_id == null }

  name        = "${each.key}-github-credentials"
  username    = each.value.git_username
  password    = each.value.git_token
  description = "GitHub credentials for ${each.key} (managed by Terraform)"
}

resource "jenkins_job" "this" {
  for_each = var.pipelines

  name = each.key

  depends_on = [jenkins_credential.git]

  template = templatefile("${path.module}/templates/pipeline-scm.xml.tpl", {
    description        = coalesce(each.value.description, "Terraform-managed SCM pipeline for ${each.value.application_name}")
    git_repository_url = each.value.git_repository_url
    git_branch         = each.value.git_branch
    git_credentials_id = local.credential_ids[each.key]
    jenkinsfile_path   = each.value.jenkinsfile_path
    poll_schedule      = each.value.poll_schedule
  })
}
