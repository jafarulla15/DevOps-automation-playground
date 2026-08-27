output "job_names" {
  description = "Jenkins job name for each pipeline, keyed the same as var.pipelines"
  value       = { for key, job in jenkins_job.this : key => job.name }
}

output "image_names" {
  description = "Computed Docker image name per pipeline, keyed the same as var.pipelines"
  value       = local.image_names
}
