# opencode-workflow-demo

A standard template for OpenCode projects: a coding workflow, a progressive GitHub Actions CI/CD pipeline, and strict semantic versioning. The contents of `codebase/` are project-specific; everything else is reusable infrastructure.

## Structure

```
.
├── AGENTS.md              # OpenCode session guidance (read before editing)
├── CHANGELOG.md           # versioned changelog, managed by the pipeline
├── codebase/              # project implementation (replace per project)
│   ├── .env.example       # source of truth for configurable knobs
│   ├── docker-compose.yml # reads env for ports + NIC
│   ├── Dockerfile         # container image build
│   └── html/              # placeholder app content
├── docbase/               # all documentation
│   ├── TOCTREE.md         # index of every doc
│   ├── docs/*.md          # charter, SRS, architecture, API, ERD, ...
│   └── site/              # React + Vite docs site deployed to GitHub Pages
└── .github/workflows/     # CI/CD pipeline
```

## Workflow

Every change follows six steps (see `AGENTS.md`): capture the requirement → implement in `codebase/` → document in `docbase/` → update `CHANGELOG.md` → commit to `dev-001` → CI/CD runs.

## Branch model

```
dev-001 → dev → main → GitHub Pages
```

- Work only on `dev-001`.
- `dev-001 → dev`: fast checks (compose validation, image build, lint).
- `dev → main`: quality gates — CodeQL (SAST) + SonarQube Cloud (quality gate), fail closed.
- `main → GitHub Pages`: build and deploy the React + Vite docs site.

Promotion is automated; never push directly to `dev` or `main`.

## Versioning

Strict `major.minor.patch`. The `release` job derives the bump from conventional commit subjects:

- `feat!:` or `BREAKING CHANGE:` → major
- `feat:` → minor
- everything else → patch

## Prerequisites

Configure secrets and Pages from a local `.env` (auto-config):

```bash
cp .env.example .env          # fill in PROMOTE_TOKEN and SONAR_TOKEN
./scripts/configure-secrets.sh
```

What you need before filling in `.env`:

- **`PROMOTE_TOKEN`** — GitHub PAT with `repo` + `workflow` scopes (PRs created by `GITHUB_TOKEN` don't trigger checks, so promotion needs a PAT).
- **`SONAR_TOKEN`** — SonarQube Cloud token (SonarCloud → My Account → Security).
- GitHub Pages source set to **GitHub Actions** (the script does this; or set it manually under Settings → Pages).

Real `.env` is gitignored — never commit it.

## Quick start

```bash
cp codebase/.env.example codebase/.env
docker compose --env-file codebase/.env --project-directory codebase up --build
```

Open <http://127.0.0.1:8080>.

## Using this as a template

1. Create a new repo from this template.
2. Replace `codebase/` with your implementation; update `.env.example`, `Dockerfile`, `docker-compose.yml`.
3. Fill in `docbase/docs/*.md` for your project.
4. Set `base` in `docbase/site/vite.config.ts` to `/<your-repo>/`.
5. Update `sonar-project.properties` (`sonar.organization`, `sonar.projectKey`, `sonar.projectName`).
6. Configure the secrets and Pages source above.
