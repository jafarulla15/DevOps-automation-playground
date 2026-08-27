variable "files_dir" {
  description = "Directory containing one self-contained Jenkinsfile per application. Each *.Jenkinsfile becomes one Jenkins pipeline job named after the file (without extension) - drop in a new file and re-apply to add a pipeline, no other Terraform changes needed."
  type        = string
}

variable "file_suffix" {
  description = "Filename suffix (including the leading dot) identifying pipeline definition files in files_dir"
  type        = string
  default     = ".Jenkinsfile"
}
