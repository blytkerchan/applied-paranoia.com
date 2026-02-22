# applied-paranoia.com

## Local site development

To build and serve the site locally, install a recent Ruby and Bundler.

```bash
bundle install
bundle exec jekyll serve
```

Build static output:

```bash
bundle exec jekyll build
```

Ruby runtime is pinned in `.ruby-version` and GitHub Actions reads that file via `ruby/setup-ruby`.

## Infrastructure deployment (Terraform)

Infrastructure lives under `infra/` and uses an S3 backend for Terraform state.

1. Create your local environment file from the committed template:

```bash
cd infra
cp dot-env .env
```

2. Edit `.env` with your AWS credentials and deployment values (`ACM_CERTIFICATE_ARN` is required).

3. Initialize state storage (required first step):

```bash
./setup-state
```

4. Bootstrap Terraform environment (must be sourced):

```bash
. bootstrap
```

5. Plan and apply with manual review:

```bash
terraform plan --var-file=env.auto.tfvars --out=plan.tfplan
terraform apply plan.tfplan
```

### Important rules

- Never run `terraform apply --auto-approve`.
- Always review `terraform plan` output before apply.
- Never commit `.env`, `backend.tfvars`, `env.auto.tfvars`, or `*.tfstate*` files.

## Site deployment (guarded)

To deploy static site content safely (with output checks + CloudFront invalidation):

```bash
./scripts/deploy-site.sh
```

This script:
- Builds `_site`.
- Fails if non-site repo files appear in `_site`.
- Syncs `_site` to the Terraform-managed site bucket.
- Invalidates CloudFront and waits for completion.

## GitHub Actions branch workflow

- `build.yml`: runs build + output safety checks on pushes/PRs to `dev` and `prod`.
- `dependabot-auto-approve.yml`:
	- Auto-approves Dependabot PRs into `dev` after successful build checks.
	- Auto-approves Dependabot PRs into `prod` only for semver `minor`/`patch` updates after successful build checks.
- `deploy.yml`: on push to any branch, maps branch -> stage/environment and deploys if that environment exists.
- `destroy.yml`: manual workflow-dispatch to destroy a branch deployment (requires typing `DESTROY`; rejects `prod`).

Deploy workflows use GitHub Environments:
- `dev` for dev deploy/destroy workflows.
- `prod` for prod deploy workflow.

You can enforce required reviewers, wait timers, and environment-scoped secrets under repository Settings -> Environments.

`deploy.yml` derives deployment target from branch name:
- `prod` branch -> `prod` stage + `prod` environment.
- Non-`prod` branches -> branch-slug environment name + deterministic unpredictable stage (`dev-<hash>`).
- If the expected GitHub Environment does not exist, deployment is skipped.

To enable preview deployment for another branch, create a GitHub Environment named as the branch slug (lowercase, non-alphanumeric converted to `-`).

Terraform apply in CI is branch-gated by path filtering:
- If `infra/**` changed, workflow runs Terraform plan/apply for that environment first.
- If infra did not change, workflow skips Terraform apply and only deploys static site content.

### Required GitHub repository variables/secrets

Repository variables (`Settings -> Secrets and variables -> Actions -> Variables`):
- `AWS_ACCESS_KEY_ID`
- `AWS_REGION`
- `AWS_STATE_BUCKET`
- `AWS_STATE_KEY_PROD`
- `AWS_STATE_KEY_DEV`
- `ROOT_DOMAIN`
- `ACM_CERTIFICATE_ARN`

Repository secret:
- `AWS_SECRET_ACCESS_KEY`

