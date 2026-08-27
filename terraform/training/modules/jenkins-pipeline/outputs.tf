output "job_names" {
  description = "Jenkins job name for each pipeline, keyed the same as var.pipelines"
  value       = { for key, job in jenkins_job.this : key => job.name }
}

output "image_names" {
  description = "Computed Docker image name per pipeline, keyed the same as var.pipelines"
  value       = local.image_names
}

output "host_ports" {
  description = "Published host port per pipeline (null if not published), keyed the same as var.pipelines. Combine with the VM's IP at the caller to build a full URL - this module doesn't assume a specific host address."
  value       = { for key, p in var.pipelines : key => p.host_port }
}
