# Project Charter

## Vision

A reusable template that gives every OpenCode project a ready-made seven-step coding workflow, a progressive CI/CD pipeline, and strict semantic versioning — clone, replace `codebase/`, and start delivering.

## Objectives

- Provide a documented seven-step workflow that guides an OpenCode agent from requirement capture through CI/CD.
- Ship a progressive GitHub Actions pipeline with automated version bumping, branch-gated promotion, and parallel app + docs deployment.
- Enforce strict `major.minor.patch` versioning derived from conventional commits.
- Separate implementation (`codebase/`) from documentation (`docbase/`) so each can be deployed independently.

## Scope

### In scope

- Template infrastructure: `AGENTS.md`, the workflow definition, CI/CD pipeline, versioning rules, and the `docbase/` documentation set.
- A sample React + Vite application (`codebase/site/`) that demonstrates the deployment path end-to-end.
- Multi-stage Dockerfile and `docker-compose.yml` for local development.
- Secret auto-configuration script (`scripts/configure-secrets.sh`).

### Out of scope

- Project-specific business logic — consumers replace `codebase/` with their own implementation.
- Hosting infrastructure beyond GitHub Pages and GitHub Wiki.
- Database or backend services — the template ships a static SPA only.

## Stakeholders

| Name | Role | Interest |
| --- | --- | --- |
| Project maintainer | Owner | Template stays reusable, CI/CD stays green, versioning stays strict. |
| OpenCode user | Developer | Clone-and-go: minimal setup, clear workflow, automated promotion. |
| CI/CD operator | DevOps | Pipeline gates are hard, secrets are documented, promotion is automated. |

## Success criteria

- A new project can be created from this template and deploy to Pages + Wiki within 10 minutes of secret configuration.
- Every push to `dev-001` is automatically versioned, gated, promoted, and deployed — no manual intervention beyond the initial push.
- The container (`docker compose up`) and GitHub Pages ship an identical `dist/` artifact.
- Every released version has a git tag and a CHANGELOG entry.
