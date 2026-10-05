#!/usr/bin/env bash
# Configure CI/CD secrets, notification settings, GitHub Pages, and the GitHub
# Wiki from a local .env file.
#
# Usage:
#   cp .env.example .env        # then fill in real token values
#   ./scripts/configure-secrets.sh
#
# Reads variables from .env (gitignored) and stores them as encrypted
# repository secrets via `gh secret set`. Also enables GitHub Pages with
# Source = GitHub Actions, enables the repository Wiki feature, and registers
# dev-001 as a deployment branch for the github-pages environment. Never
# commits anything.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_file="$root/.env"

if [[ ! -f "$env_file" ]]; then
  echo "::error:: $env_file not found. Run: cp .env.example .env  then fill in real values."
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "::error:: GitHub CLI (gh) is not installed. Install it from https://cli.github.com/"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "::error:: Not authenticated with gh. Run: gh auth login"
  exit 1
fi

# shellcheck disable=SC1090
set -a; source "$env_file"; set +a

# Expand ${PROJECT_NAME} in NOTIFICATION_HEADER
NOTIFICATION_HEADER="${NOTIFICATION_HEADER//\$\{PROJECT_NAME\}/${PROJECT_NAME:-}}"

# ── Secrets ─────────────────────────────────────────────────────────────────
echo "Storing secrets in GitHub (values are redacted by gh)..."

# Token secrets — only set when non-empty (already-set secrets are preserved).
for var in GIT_PUSH_TOKEN PROMOTE_TOKEN SONAR_TOKEN; do
  value="${!var:-}"
  if [[ -n "$value" ]]; then
    printf '%s' "$value" | gh secret set "$var"
    echo "  set $var"
  else
    echo "  skip $var (empty — leaving existing secret unchanged)"
  fi
done

# Notification secrets — always set (even "false" is a meaningful value).
printf '%s' "${NOTIFICATION_ADDRESS:-}" | gh secret set NOTIFICATION_ADDRESS
printf '%s' "${NOTIFICATION_HEADER:-}"  | gh secret set NOTIFICATION_HEADER
printf '%s' "${NOTIFICATION_ACTIVE:-false}" | gh secret set NOTIFICATION_ACTIVE
echo "  set NOTIFICATION_ADDRESS"
echo "  set NOTIFICATION_HEADER"
echo "  set NOTIFICATION_ACTIVE"

# ── GitHub Pages ────────────────────────────────────────────────────────────
echo ""
echo "Enabling GitHub Pages (Source: GitHub Actions)..."
# build_type=workflow means "Source: GitHub Actions". Non-fatal if already on.
if gh api repos/:owner/:repo/pages >/dev/null 2>&1; then
  gh api -X PUT repos/:owner/:repo/pages -f build_type=workflow >/dev/null 2>&1 \
    && echo "  Pages already enabled; build_type set to workflow." \
    || echo "  ::warning:: Pages exists but could not set build_type=workflow. Set it in Settings → Pages."
else
  gh api -X POST repos/:owner/:repo/pages -f build_type=workflow >/dev/null 2>&1 \
    && echo "  Pages enabled with Source = GitHub Actions." \
    || echo "  ::warning:: Could not enable Pages via API. Enable it manually: Settings → Pages → Source: GitHub Actions."
fi

# ── GitHub Wiki ─────────────────────────────────────────────────────────────
echo ""
echo "Enabling GitHub Wiki..."
# Turn on the repository wiki feature. The wiki job publishes docbase/ here.
# Note: GitHub does not create the .wiki.git repo until the first page is
# saved through the web UI; the wiki job warns and skips (non-blocking)
# until then.
gh api -X PATCH repos/:owner/:repo -F has_wiki=true >/dev/null 2>&1 \
  && echo "  Wiki feature enabled. Create the first page once at {repo}/wiki to activate it." \
  || echo "  ::warning:: Could not enable the Wiki via API. Enable it manually: Settings → General → Features → Wikis."

# ── Deployment branch policy ────────────────────────────────────────────────
echo ""
echo "Configuring github-pages deployment branch policy..."
# Ensure dev-001 is an allowed deployment branch for the github-pages
# environment so Pages deploys can run from dev-001 pushes as well as main.
existing=$(gh api repos/:owner/:repo/environments/github-pages/deployment-branch-policies \
  --jq '.branch_policies[].name' 2>/dev/null || echo "")

add_branch() {
  local branch="$1"
  if grep -qx "$branch" <<< "$existing"; then
    echo "  $branch already allowed"
  else
    gh api -X POST repos/:owner/:repo/environments/github-pages/deployment-branch-policies \
      -f name="$branch" >/dev/null 2>&1 \
      && echo "  added $branch" \
      || echo "  ::warning:: Could not add $branch to deployment branch policy."
  fi
}

add_branch "dev-001"
add_branch "main"

echo ""
echo "Done. Re-run the workflow to verify promotion:"
echo "  gh workflow run ci-cd.yml --ref dev-001"
