output "job_names" {
  description = "Jenkins job name for each pipeline, keyed the same as var.pipelines"
  value       = { for key, job in jenkins_job.this : key => job.name }
}

output "credential_ids" {
  description = "Jenkins credential ID used by each pipeline, keyed the same as var.pipelines"
  value       = local.credential_ids
}
