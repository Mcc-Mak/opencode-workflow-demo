# CI/CD Pipeline

## Branch model

```
dev-001 → dev → main → GitHub Pages
```

Working branch is always `dev-001`. Promotion is automated by GitHub Actions; never push directly to `dev` or `main`.

## Stages

| Hop | Workflow job | Purpose |
| --- | --- | --- |
| `dev-001` push | `release` | Bump version (`major.minor.patch`) from conventional commits and update `CHANGELOG.md`. |
| `dev-001` → `dev` | `fast_checks` | Validate compose, build the image, lint. Gates the promotion PR. |
| `dev` → `main` | `security_checks` | CodeQL (SAST) + SonarQube Cloud (SCA + quality gate). Fails closed on findings. |
| `main` → Pages | `pages` | Build the React + Vite docs site and deploy to GitHub Pages. |

## Versioning

Versions are strict `major.minor.patch`. The `release` job parses commit subjects since the last `chore(release):` commit:

- `feat:` / `feat!:` → minor (or major if breaking)
- `fix:` → patch
- `BREAKING CHANGE:` in a body → major
- anything else → patch

## Required secrets

- `SONAR_TOKEN` — SonarQube Cloud token.
- `PROMOTE_TOKEN` — GitHub PAT with `repo` and `workflow` scopes.

## Repository settings

- Enable GitHub Pages: **Settings → Pages → Source: GitHub Actions**.
- Protect `dev` and `main`; require the matching status checks before merge.
