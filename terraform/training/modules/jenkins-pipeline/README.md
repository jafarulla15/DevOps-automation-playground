# modules/jenkins-pipeline

Creates one Jenkins pipeline job per entry in `var.pipelines`. Each entry
supplies one application's specifics (repo, credentials, image/container
name, ports) - onboarding a new application is purely a matter of adding a
map entry, no Groovy, no new files, regardless of language or framework.

## How it works

- `templates/app.Jenkinsfile.tpl` is a single generic pipeline: Checkout →
  `docker build .` → `docker push` → `docker run`. All language/framework-
  specific build logic (dotnet restore/build/test, npm ci/build, etc.) lives
  in **the application's own Dockerfile**, not in this module - that's what
  makes one template work for any stack.
- For each `var.pipelines` entry, Terraform renders that template with the
  entry's values, then wraps the result as a Jenkins "Pipeline script" job
  (`templates/pipeline-script.xml.tpl`, `CpsFlowDefinition`, CDATA-wrapped).
- Because it's an inline "Pipeline script" (not "from SCM"), there's no
  implicit `scm` - the template includes an explicit `git branch: ...,
  credentialsId: ..., url: ...` Checkout step using the entry's repo details.

**Why not run `dotnet`/`npm` directly in Jenkins?** We tried that first (per-
stack templates with `dotnet restore/build/test` or `npm ci`/`build` stages
running directly in the Jenkins container). It broke the first time a real
repo didn't have its project file at the repo root (a nested `.csproj` in a
subdirectory) - the multi-stage Dockerfile the app owner already wrote knew
how to handle that; our generic Jenkins-side assumption didn't. Delegating
100% of the build to `docker build .` avoids ever needing to know an app's
internal layout, and also means Jenkins itself doesn't need any
language-specific SDKs installed.

## Adding a new application

Add an entry to `var.pipelines` - see example below. The only requirement is
that the target repo has a working `Dockerfile` that builds and runs the app
standalone (`docker build . && docker run <image>` should just work).

## Example usage

```hcl
module "app_pipelines" {
  source = "./modules/jenkins-pipeline"

  pipelines = {
    dotnet-api = {
      application_name   = "earn-dotnet-api"
      git_repository_url = "https://github.com/jafarulla15/DevOps-Demo-REST-Api.git"
      git_credentials_id = "github-jenkins-pat"
      docker_registry    = "192.168.238.50:5000"
      container_name     = "demo-dotnet-api"
      container_port     = 8070
      host_port          = 5000
      docker_network     = "monitoring"
    }

    angular-app = {
      application_name   = "earn-angular-app"
      git_repository_url = "https://github.com/jafarulla15/DevOps-Demo-Angular.git"
      git_credentials_id = "github-jenkins-pat"
      docker_registry    = "192.168.238.50:5000"
      container_name     = "demo-angular-app"
      container_port     = 80
      host_port          = 4600
      docker_network     = "monitoring"
    }
  }

  depends_on = [module.jenkins]
}
```

## Template-writer's note: two layers of `${...}`

The template mixes **two** substitution layers that both use `${...}`
syntax, and it's easy to get them mixed up when editing:

1. **Terraform-level** (`templatefile()`): resolved once, at `plan`/`apply`
   time, into a literal baked-in value - e.g. `${git_repository_url}`,
   `${image_name}`.
2. **Jenkins/Groovy-runtime** (`environment{}` variables, `$BUILD_NUMBER`):
   must survive Terraform's render untouched, to be evaluated by Jenkins
   each time the job runs.

Since Terraform's `templatefile()` only triggers on `${` (curly braces),
every runtime reference in the template is written **without** braces -
`$IMAGE_NAME`, `$BUILD_NUMBER`, `$CONTAINER_NAME` - inside single-quoted
`sh '''...'''` blocks, relying on real shell environment-variable expansion
(Jenkins exports `environment{}` values as actual process env vars). If you
add a new stage and accidentally write `${IMAGE_NAME}` instead of
`$IMAGE_NAME`, Terraform will fail the render with "vars map does not
contain key IMAGE_NAME" - that error is your signal you used the wrong
syntax for a runtime variable.

## Variables

See `variables.tf`. Required per pipeline entry: `application_name`,
`git_repository_url`, `git_credentials_id`, `container_name`,
`container_port`. Optional: `git_branch` (default `main`),
`docker_registry`, `host_port`, `docker_network`, `poll_schedule`.

`git_credentials_id` must reference a credential that **already exists** in
Jenkins - this module doesn't create credentials. If it's missing, the
Checkout stage fails with "credentials not found" the first time the job
runs (public repos will still check out fine without it, but the credential
should exist before you ever point this at a private repo).

## Outputs

- `job_names` - Jenkins job name per pipeline.
- `image_names` - the computed Docker image name per pipeline
  (`<docker_registry>/<container_name>`, or just `<container_name>` if
  `docker_registry` is empty).

## Gotchas

- `poll_schedule` adds a `triggers { cron(...) }` block *inside* the
  script, which reruns unconditionally on that schedule - it is **not**
  SCM-change-aware polling (that requires job-level SCM config, which
  inline "Pipeline script" jobs don't have). Leave it unset for manual
  builds only.
- If `docker_network` is set, the deployed container joins it - required
  for `modules/nginx` to reverse-proxy to it by container name.
- If `host_port` is set, the container's port is also published on the
  host directly, independent of `docker_network`.
- `container_port` must match whatever port the app's own Dockerfile
  actually exposes/listens on (check its `EXPOSE`/`ENV ASPNETCORE_URLS`/
  equivalent) - this module doesn't inspect the Dockerfile, so a mismatch
  here means the container runs but nothing reaches it.
