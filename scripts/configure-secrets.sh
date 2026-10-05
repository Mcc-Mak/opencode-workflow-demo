#!/usr/bin/env bash
# Configure CI/CD secrets and GitHub Pages from a local .env file.
#
# Usage:
#   cp .env.example .env        # then fill in real token values
#   ./scripts/configure-secrets.sh
#
# Reads PROMOTE_TOKEN and SONAR_TOKEN from .env (gitignored) and stores them
# as encrypted repository secrets via `gh secret set`. Also enables GitHub
# Pages with Source = GitHub Actions. Never commits anything.

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

missing=()
[[ -z "${PROMOTE_TOKEN:-}" ]] && missing+=("PROMOTE_TOKEN")
[[ -z "${SONAR_TOKEN:-}"   ]] && missing+=("SONAR_TOKEN")
if [[ ${#missing[@]} -gt 0 ]]; then
  echo "::error:: ${missing[*]} not set in $env_file. Fill them in before running this script."
  exit 1
fi

echo "Storing secrets in GitHub (values are redacted by gh)..."
printf '%s' "$PROMOTE_TOKEN" | gh secret set PROMOTE_TOKEN
printf '%s' "$SONAR_TOKEN"   | gh secret set SONAR_TOKEN
echo "  set PROMOTE_TOKEN"
echo "  set SONAR_TOKEN"

echo "Enabling GitHub Pages (Source: GitHub Actions)..."
# build_type=workflow means "Source: GitHub Actions". Non-fatal if already on.
if gh api repos/:owner/:repo/pages >/dev/null 2>&1; then
  gh api -X PUT repos/:owner/:repo/pages -f build_type=workflow >/dev/null 2>&1 \
    && echo "  Pages already enabled; build_type set to workflow." \
    || echo "  ::warning:: Pages exists but could not set build_type=workflow. Set it in Settings -> Pages."
else
  gh api -X POST repos/:owner/:repo/pages -f build_type=workflow >/dev/null 2>&1 \
    && echo "  Pages enabled with Source = GitHub Actions." \
    || echo "  ::warning:: Could not enable Pages via API. Enable it manually: Settings -> Pages -> Source: GitHub Actions."
fi

echo ""
echo "Done. Re-run the workflow to verify promotion:"
echo "  gh workflow run ci-cd.yml --ref dev-001"
