locals {
  pipeline_files = fileset(var.files_dir, "*${var.file_suffix}")

  # Job name is the filename without its suffix, e.g. "dotnet.Jenkinsfile" -> "dotnet"
  pipelines = {
    for f in local.pipeline_files :
    trimsuffix(f, var.file_suffix) => "${var.files_dir}/${f}"
  }
}

resource "jenkins_job" "this" {
  for_each = local.pipelines

  name = each.key

  template = templatefile("${path.module}/templates/pipeline-script.xml.tpl", {
    description = "Terraform-managed pipeline for ${each.key} (source: ${each.value})"
    script      = file(each.value)
  })
}
