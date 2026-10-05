# AGENTS.md

Compact guidance for OpenCode sessions working in this repo. Read before editing.

## Repository purpose

A reusable template for OpenCode projects: a six-step coding workflow, a progressive GitHub Actions CI/CD pipeline, and strict semantic versioning. The contents of `codebase/` are project-specific; everything else (`AGENTS.md`, `docbase/`, the workflow, versioning) is reusable infrastructure. Use this repo as a template and replace `codebase/` per project.

## Layout

Code and docs are strictly separated. Do not mix them.

- `codebase/` — all implementation (project-specific; replace per project)
  - `.env.example` — every env var (PORT, NIC, image tag, etc.) with safe defaults
  - `docker-compose.yml` — compose that reads env for ports + NIC
  - `Dockerfile` / `Dockerfile.*` — one or more Dockerfiles (e.g. `Dockerfile.opencode`)
- `docbase/` — all documentation
  - `TOCTREE.md` — index linking every doc below
  - `docs/ProjectCharter.md`, `UserStories.md`, `PRD.md`, `SRS.md`, `PDR.md`, `ADR.md`,
    `Architecture.md`, `API.md`, `Schema.md`, `ERD.md`, `QuickStart.md`,
    `Configurations.md`, `CICD-Pipeline.md`, `RTM.md`, `CRM.md`
  - `site/` — React + Vite docs site, built and deployed to GitHub Pages on push to `main`
  - **CRM** = Cross-Reference Matrix (maps requirements → docs → tests). Keep it updated when requirements change.
- `CHANGELOG.md` (repo root) — one entry per change, versioned `major.minor.patch`
- `.env.example` (repo root) — documents CI/CD secrets (`PROMOTE_TOKEN`, `SONAR_TOKEN`); copy to gitignored `.env` and run `scripts/configure-secrets.sh`
- `scripts/configure-secrets.sh` — pushes local `.env` secret values into GitHub's encrypted store and enables Pages
- `.github/workflows/*.yml` — CI/CD pipelines

When adding a doc, also add it to `docbase/TOCTREE.md`. When adding an env var, also add it to `codebase/.env.example`.

## Workflow (follow in order)

Every task follows these 6 steps, in order:

1. **User Requirement** — capture the ask before coding.
2. **Implement** into `codebase/{.env.example,docker-compose.yml,Dockerfile.*}`. Ports and NIC come from `.env`.
3. **Document** into `docbase/` (all files listed above, TOCTREE updated). CRM must reflect new/changed requirements.
4. **Update `CHANGELOG.md`** — add entry with version `major.minor.patch`.
5. **Git** — commit to branch `dev-001`:
   - Subject includes the version: `major.minor.patch` (e.g. `<scope>: ... (0.1.0)`)
   - Body explains the what and why
   - Push `dev-001` to `origin/dev-001`. Do **not** push to `dev` or `main` manually.
6. **CI/CD** runs automatically (see below).

Do not skip steps 3–4. Implementation without docs + changelog is incomplete.

## Git & branching

- Working branch is always **`dev-001`**. Commit and push there only.
- Promotion is automated by GitHub Actions, not manual:
  `origin/dev-001` → `origin/dev` → `origin/main` → **GitHub Pages**
- Never force-push. Never commit directly to `main` or `dev`.

## CI/CD pipelines (`.github/workflows/*.yml`)

The pipeline has progressive stages, one per promotion hop:

- **`dev-001` push** — `release` job bumps the version and updates `CHANGELOG.md` from conventional commits (runs before promotion).
- **`dev-001` → `dev`**: `fast_checks` job — validate compose, build the image, lint. Gates this hop.
- **`dev` → `main`**: `security_checks` job — **CodeQL** (SAST) + **SonarQube Cloud** (quality gate). This hop must fail closed on findings.
- **`main` → GitHub Pages**: `pages` job — build the **React + Vite** site (`docbase/site/`) and deploy to Pages.

Promotion is driven by the `promote` job, which opens PRs `dev-001 → dev` and `dev → main` and merges each only after its gate check passes. It uses `PROMOTE_TOKEN` (a PAT) so the PRs trigger the gate workflow runs.

When editing workflows, preserve the stage boundaries and the SonarQube/CodeQL gates on the `dev → main` hop.

## Conventions

- Versioning is strict `major.minor.patch`; bump per CHANGELOG entry.
- `.env.example` is the source of truth for configurable knobs. Real `.env` is never committed.
- Prefer editing existing files over creating new ones; only create files listed in the Layout section.
