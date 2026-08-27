output "job_name" {
  value = jenkins_job.application_pipeline.name
}

output "git_credentials_id" {
  value = jenkins_credential.git.name
}
