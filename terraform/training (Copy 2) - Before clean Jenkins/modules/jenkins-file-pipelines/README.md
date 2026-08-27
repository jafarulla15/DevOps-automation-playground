# modules/jenkins-file-pipelines

Auto-discovers one Jenkins pipeline job per file in a directory. Drop in a
new `<name>.Jenkinsfile`, run `terraform apply`, and a new Jenkins job named
`<name>` appears — no Terraform code changes needed per application.

Unlike [`modules/jenkins-scm-pipeline`](../jenkins-scm-pipeline/README.md)
(which fetches the pipeline script from each *application's own* GitHub
repo), this module keeps every pipeline definition centrally in **this**
repo, under `var.files_dir`. That's the point of this module: you manage
pipeline definitions here, not scattered across every app's repo.

## How it works

- `local.pipeline_files = fileset(var.files_dir, "*.Jenkinsfile")` scans the
  directory at plan time — this is what makes adding a file enough to create
  a new pipeline on the next `apply`, with zero other Terraform changes.
- The job name is the filename with the `.Jenkinsfile` suffix stripped
  (`dotnet.Jenkinsfile` → job `dotnet`).
- Each file's raw content becomes the job's **Pipeline script** (Jenkins
  `CpsFlowDefinition`, inline) via `file()` + a CDATA-wrapped template — not
  "Pipeline script from SCM".

## Why each Jenkinsfile needs its own explicit checkout

Because the job type is inline "Pipeline script," not "from SCM," there is
**no implicit `scm` variable** — a job like this cannot use `checkout scm`.
Each file must check out its actual application source explicitly, e.g.:

```groovy
environment {
    GIT_REPO_URL       = "https://github.com/you/your-app"
    GIT_BRANCH         = "main"
    GIT_CREDENTIALS_ID = "github-jenkins-pat"
}

stages {
    stage('Checkout') {
        steps {
            git branch: "${GIT_BRANCH}",
                credentialsId: "${GIT_CREDENTIALS_ID}",
                url: "${GIT_REPO_URL}"
        }
    }
    // ...build/test/docker/deploy stages
}
```

`GIT_CREDENTIALS_ID` must reference a credential that already exists in
Jenkins (create it manually, or via `modules/jenkins-scm-pipeline`'s
credential-creation path) — this module does not create credentials itself.

## Example usage

```hcl
module "app_file_pipelines" {
  source = "./modules/jenkins-file-pipelines"

  files_dir = "${path.root}/modules/jenkins/files"

  depends_on = [module.jenkins]
}
```

## Variables

- `files_dir` (required) — directory to scan for `*.Jenkinsfile` files.
- `file_suffix` (default `.Jenkinsfile`) — override if you prefer a
  different naming convention.

## Outputs

- `job_names` — list of Jenkins job names created (one per discovered file).
- `source_files` — map of job name → source file path, for traceability.

## Gotchas

- **No automatic build trigger.** Because there's no job-level SCM, Jenkins'
  `pollSCM`/`SCMTrigger` (used by `modules/jenkins-scm-pipeline`) doesn't
  apply here - there's nothing at the job-definition level for it to poll.
  Builds are manual (**Build Now**) unless you add your own trigger inside
  the Jenkinsfile itself (e.g. a `cron()` trigger, which reruns on a
  schedule regardless of whether anything changed, or a GitHub webhook
  calling this job's build URL directly).
- Renaming a file changes its job name - Terraform will create a job under
  the new name and **leave the old one orphaned** in Jenkins (this module
  only ever creates/updates jobs matching current files; it doesn't track
  previous names to delete them). Remove the old job manually via the
  Jenkins UI, or `terraform state rm`/import as needed.
- Deleting a file removes it from `local.pipelines`, so Terraform will plan
  to **destroy** that Jenkins job on the next apply - review the plan before
  applying if you didn't mean to remove a pipeline.
- Script content containing the literal sequence `]]>` would break the
  CDATA wrapping used to embed it - vanishingly unlikely in a normal
  Jenkinsfile, but worth knowing if a build ever fails with an XML parse
  error right after adding a new file.
