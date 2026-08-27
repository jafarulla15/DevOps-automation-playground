output "job_names" {
  description = "Jenkins job name for each discovered pipeline file"
  value       = keys(local.pipelines)
}

output "source_files" {
  description = "Source Jenkinsfile path used for each job, keyed by job name"
  value       = local.pipelines
}
