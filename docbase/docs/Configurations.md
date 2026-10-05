# Configurations

All configurable knobs live in `codebase/.env.example`. Copy it to `codebase/.env` and adjust. Real `.env` files are never committed.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `PORT` | `8080` | Host port mapped to the container. |
| `NIC` | `127.0.0.1` | Network interface the port binds to. Use `0.0.0.0` to expose publicly. |
| `IMAGE_TAG` | `latest` | Tag applied to the built image. |

## CI/CD secrets

These are stored as encrypted **repository secrets** (GitHub-hosted runners cannot read a local `.env` at runtime). Configure them from a local `.env` via the auto-config script:

```bash
cp .env.example .env          # fill in real token values
./scripts/configure-secrets.sh
```

The script pushes each value into GitHub's secret store with `gh secret set` and enables GitHub Pages. Real `.env` is gitignored.

| Secret | Used by | Description |
| --- | --- | --- |
| `PROMOTE_TOKEN` | auto-promote | PAT that creates/merges promotion PRs (GITHUB_TOKEN PRs do not trigger checks). Scopes: `repo`, `workflow`. |
| `SONAR_TOKEN` | security gate | SonarQube Cloud analysis token. |

## Docs site

The GitHub Pages site (`docbase/site/`) deploys at the path matching the repository name. If you rename the repo, update `base` in `docbase/site/vite.config.ts`.
