# Handoff: OIDC migration + environments/bootstrap baseline (PR #37)

Claude is stepping back (session credit limit) - here's the full state and
next steps for whoever picks this up next (Copilot or otherwise).

## Where this PR stands

All Terraform/CI work for the environments/bootstrap baseline + OIDC deploy
role is done and passing CI (`terraform` job runs `terraform test` - 8
mocked tests, no AWS needed; `tflint`, `checkov`, `trivy` all pass). Four
rounds of Copilot review have been addressed and replied to inline on
[PR #37](https://github.com/blytkerchan/applied-paranoia.com/pull/37) -
nothing outstanding on the diff itself. **Nothing has been applied to real
AWS yet** - every check in this PR (including the `terraform`/`deploy` jobs
in `deploy.yml`) either runs against a mocked/local backend or is gated off
by `env_exists` (no GitHub Environment exists yet for this branch name), so
opening/pushing to this PR has never triggered a live change.

## What this PR does NOT do (deliberately deferred)

`deploy.yml`/`destroy.yml` still authenticate to AWS with the old static
`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`. The OIDC role this PR defines
(`module.github_oidc`, owned by the `devops` state) doesn't exist in AWS
yet - it can't be referenced by a workflow until it's actually created,
which is a chicken-and-egg that has to happen in this order:

## Exact next steps, in order

1. **Get human review/approval on this PR as-is** from @blytkerchan before
   touching AWS. This repo's own `.github/copilot-instructions.md` has a
   hard rule: never `terraform apply --auto-approve`, always plan → human
   review → apply. That rule applies here too.

2. **Apply the `devops` environment first** (creates the OIDC provider +
   role - nothing else, verified via a real plan: `3 to add, 0 to change,
   0 to destroy`):

   ```bash
   cd infra
   . bootstrap devops
   terraform plan -out plan.tfplan -var-file=environments/devops/terraform.tfvars
   # STOP - show the plan to @blytkerchan for explicit approval before continuing
   terraform apply plan.tfplan
   terraform output site_deploy_role_arn
   ```

   Whoever runs this needs real AWS credentials for account `981855120431`
   (blytkerchan's personal account) - either the local AWS CLI already
   configured there, or an AWS access grant for the agent environment
   specifically. This is *not* something that can be run from a sandbox
   with no AWS access.

3. **Set the resulting ARN as a repo variable** (e.g. `SITE_DEPLOY_ROLE_ARN`):

   ```bash
   gh api -X PUT repos/blytkerchan/applied-paranoia.com/actions/variables/SITE_DEPLOY_ROLE_ARN -f value=<arn>
   ```

   (or via the GitHub UI: Settings → Secrets and variables → Actions → Variables)

4. **Open a follow-up PR** that swaps `deploy.yml`/`destroy.yml`'s AWS
   credentials step from static keys to OIDC:

   ```yaml
   permissions:
     id-token: write   # add this - required for OIDC, not currently present
     contents: read
   # ...
   - name: Configure AWS credentials
     uses: aws-actions/configure-aws-credentials@v6
     with:
       role-to-assume: ${{ vars.SITE_DEPLOY_ROLE_ARN }}
       aws-region: ${{ vars.AWS_REGION }}
   ```

   Verify a **real** deploy succeeds via OIDC (push to a preview branch,
   confirm the `terraform`/`deploy` jobs in `deploy.yml` actually run and
   succeed with `role-to-assume`) before touching the old credentials.

5. **Only after step 4 is verified**, remove the old
   `AWS_ACCESS_KEY_ID` variable and `AWS_SECRET_ACCESS_KEY` secret.

6. **Apply `dev` and `prod`** whenever convenient (not urgent - the next
   real `deploy.yml` run will apply them anyway as part of normal site
   deploys). Real plans against live state already verified clean: 5 of 7
   resources show as exact no-diff address moves (thanks to `moved.tf`);
   the remaining 2 (`aws_cloudfront_distribution.site`,
   `aws_s3_bucket_policy.site`) show one attribute
   (`response_completion_timeout`) as `known after apply` - this traces to
   the mandatory AWS provider 5→6 bump (the shared OIDC module requires
   `>= 6.0`), not the environments refactor. Benign, but worth a human
   glance at the real plan output before applying, same as any other prod
   change.

7. **Merge this PR** into `dev` once the above is done (or in whatever
   order @blytkerchan prefers - steps 2-3 could also happen in a stacked
   PR after merge, if preferred over holding this one open).

## Known, accepted, non-blocking gaps (don't try to "fix" these blind)

- [Issue #38](https://github.com/blytkerchan/applied-paranoia.com/issues/38):
  13 checkov + 2 trivy findings (CloudFront WAF/access-logging/
  geo-restriction, S3 versioning/replication/KMS/lifecycle) - enterprise-
  hardening trade-offs judged not worth the cost/complexity for a personal
  static site, intentionally left non-blocking (`continue-on-error: true`
  in `ci_validate_infrastructure.yml`), not required before merge.
- `CKV_TF_1` (module source pinned to a tag, not a commit hash) is
  intentionally skip-configured - matches `vln-devsecops/github-runners`'
  identical existing policy on the same shared module.

## Related work in the broader portfolio (separate repo, FYI only)

`vln-devsecops/operations` tracks a similar OIDC migration still pending
for `VlinderSoftware/doxchange` (that repo's deploy pipeline also uses
static AWS keys) - see `docs/notes/oidc-audit-2026-07-12.md` in that repo
if picking that up too. Not part of this PR or this repo.

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
