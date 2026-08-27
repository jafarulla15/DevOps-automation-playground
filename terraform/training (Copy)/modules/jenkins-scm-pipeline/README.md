# modules/jenkins-scm-pipeline

Creates one or more Jenkins **"Pipeline script from SCM"** jobs. Unlike
[`modules/jenkins-pipeline`](../jenkins-pipeline/README.md), this module never
embeds build/test/deploy steps in Terraform — each job simply checks out a
GitHub repository and runs the `Jenkinsfile` already committed there. That
makes the module reusable across any number of applications without editing
its code: to onboard a new app, add an entry to `var.pipelines` and make sure
that repo has a `Jenkinsfile`.

## How it works

- `var.pipelines` is a map keyed by a unique Jenkins job name. Each entry
  describes one pipeline: which repo/branch to build, where its `Jenkinsfile`
  lives, how often Jenkins should poll for changes, and which credentials to
  use.
- For each entry, the module creates a `jenkins_job` configured as "Pipeline
  script from SCM" (Git), with an SCM-polling trigger (`hudson.triggers.SCMTrigger`)
  on `poll_schedule` — no GitHub webhook is required, which fits a Jenkins
  instance that isn't reachable from the public internet.
- Credentials: either point an entry at an existing Jenkins credential via
  `git_credentials_id`, or supply `git_username`/`git_token` and the module
  creates a new username/password credential named `<key>-github-credentials`.

## Example usage

```hcl
module "app_pipelines" {
  source = "./modules/jenkins-scm-pipeline"

  pipelines = {
    "earn-api" = {
      application_name   = "earn-api"
      git_repository_url = "https://github.com/jafarulla15/earn-api.git"
      git_branch          = "main"
      git_username        = var.git_username
      git_token           = var.git_token
    }

    "earn-web" = {
      application_name   = "earn-web"
      git_repository_url = "https://github.com/jafarulla15/earn-web.git"
      git_branch          = "main"
      jenkinsfile_path    = "ci/Jenkinsfile"
      poll_schedule       = "H/2 * * * *"
      git_credentials_id  = "github-credentials" # reuse an existing credential
    }
  }

  depends_on = [module.jenkins]
}
```

## Requirements

- The target Jenkins instance (`modules/jenkins` in this repo) must already
  be running and reachable via the `jenkins` provider configured in root
  `providers.tf` before this module can apply.
- Each target repository must contain a `Jenkinsfile` at `jenkinsfile_path`
  (default: `Jenkinsfile` at the repo root). Until it exists, builds will
  fail when Jenkins tries to resolve the pipeline script — the job itself
  will still be created successfully by Terraform.

## Variables

See `variables.tf`. All fields except `application_name` and
`git_repository_url` are optional per pipeline entry:

| Field | Default |
|---|---|
| `git_branch` | `main` |
| `jenkinsfile_path` | `Jenkinsfile` |
| `poll_schedule` | `H/5 * * * *` (every ~5 minutes) |
| `description` | `Terraform-managed SCM pipeline for <application_name>` |

Either `git_credentials_id`, or both `git_username` and `git_token`, must be
set per entry (enforced by a variable validation block).

## Outputs

- `job_names` — the Jenkins job name per pipeline, keyed like `var.pipelines`.
- `credential_ids` — the Jenkins credential ID actually used per pipeline
  (whichever was reused or created), keyed like `var.pipelines`.

## Gotchas

- Job names must be unique within the same Jenkins folder/root — reusing a
  key already used by another module (e.g. `modules/jenkins-pipeline`) for
  the same app will create a second, separate job rather than colliding, but
  can be confusing. Pick distinct names if both modules target the same app.
- Polling adds load proportional to `poll_schedule` frequency and the number
  of pipelines; tighten it per pipeline only where fast feedback is worth it.
