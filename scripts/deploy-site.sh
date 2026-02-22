#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Building site..."
bundle exec jekyll build

forbidden_paths=(
  "_site/infra"
  "_site/functions"
  "_site/.github"
  "_site/.devcontainer"
  "_site/README.md"
  "_site/build.ps1"
  "_site/serve.ps1"
  "_site/Gemfile"
  "_site/Gemfile.lock"
  "_site/package.json"
  "_site/package-lock.json"
  "_site/serverless.yml"
)

for path in "${forbidden_paths[@]}"; do
  if [[ -e "$path" ]]; then
    echo "ERROR: Forbidden path found in generated site output: $path"
    echo "Refusing to deploy."
    exit 1
  fi
done

echo "Bootstrapping Terraform/AWS context..."
pushd infra >/dev/null
. ./bootstrap

bucket_name="$(terraform output -raw s3_bucket_name)"
distribution_id="$(terraform output -raw cloudfront_distribution_id)"
popd >/dev/null

echo "Syncing _site to s3://${bucket_name} ..."
aws s3 sync _site "s3://${bucket_name}" --delete \
  --exclude "infra/*" \
  --exclude "functions/*" \
  --exclude ".github/*" \
  --exclude ".devcontainer/*" \
  --exclude "README.md" \
  --exclude "build.ps1" \
  --exclude "serve.ps1" \
  --exclude "Gemfile" \
  --exclude "Gemfile.lock" \
  --exclude "package.json" \
  --exclude "package-lock.json" \
  --exclude "serverless.yml"

echo "Creating CloudFront invalidation..."
invalidation_id="$(aws cloudfront create-invalidation --distribution-id "$distribution_id" --paths '/*' --query 'Invalidation.Id' --output text)"
echo "Invalidation created: ${invalidation_id}"

echo "Waiting for invalidation completion..."
aws cloudfront wait invalidation-completed --distribution-id "$distribution_id" --id "$invalidation_id"
echo "Deploy complete."
