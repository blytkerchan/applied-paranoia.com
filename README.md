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

## TODO

- Add a Dependabot configuration to keep `.devcontainer/` and Ruby dependencies up to date.

