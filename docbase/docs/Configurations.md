# Configurations

All configurable knobs live in `codebase/.env.example`. Copy it to `codebase/.env` and adjust. Real `.env` files are never committed.

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `PORT` | `8080` | Host port mapped to the container. |
| `NIC` | `127.0.0.1` | Network interface the port binds to. Use `0.0.0.0` to expose publicly. |
| `IMAGE_TAG` | `latest` | Tag applied to the built image. |

## CI/CD secrets

| Secret | Used by | Description |
| --- | --- | --- |
| `SONAR_TOKEN` | security gate | SonarQube Cloud analysis token. |
| `PROMOTE_TOKEN` | auto-promote | PAT that creates/merges promotion PRs (GITHUB_TOKEN PRs do not trigger checks). |

## Docs site

The GitHub Pages site (`docbase/site/`) deploys at the path matching the repository name. If you rename the repo, update `base` in `docbase/site/vite.config.ts`.
