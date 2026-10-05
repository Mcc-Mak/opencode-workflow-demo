# opencode-workflow-demo

> **Deployments:**
>
> | Target | URL |
> | --- | --- |
> | App (Vite) → GitHub Pages | <https://mcc-mak.github.io/opencode-workflow-demo/> |
> | Docs (markdown) → GitHub Wiki | <https://github.com/mcc-mak/opencode-workflow-demo/wiki> |
>
> **Full documentation index:** [`docbase/TOCTREE.md`](docbase/TOCTREE.md)

A standard template for OpenCode projects: a coding workflow, a progressive GitHub Actions CI/CD pipeline, and strict semantic versioning. The contents of `codebase/` are project-specific; everything else is reusable infrastructure.

## CI/CD pipeline (Mermaid)

```mermaid
flowchart LR
  subgraph dev001["dev-001"]
    PUSH["push"] --> RELEASE["release\nversion + CHANGELOG"]
    RELEASE --> FAST["fast_checks\ncompose • build • lint"]
    FAST --> PROMOTE["promote"]
  end
  subgraph dev["dev"]
    PR1["PR dev-001→dev\ngate: Fast Checks"]
  end
  subgraph main["main"]
    PR2["PR dev→main\ngate: Security & Quality"]
  end
  subgraph pages["Pages"]
    DEPLOY["Vite app deploy"]
  end
  subgraph wiki["Wiki"]
    SYNC["docbase sync"]
  end
  PROMOTE -->|merge| PR1 -->|trigger| PR2 -->|merge| DEPLOY
  PR2 -->|merge| SYNC
```

## Structure

```
.
├── AGENTS.md              # OpenCode session guidance (read before editing)
├── CHANGELOG.md           # versioned changelog, managed by the pipeline
├── codebase/              # project implementation (replace per project)
│   ├── .env.example       # source of truth for configurable knobs
│   ├── docker-compose.yml # reads env for ports + NIC
│   ├── Dockerfile         # multi-stage: node builds Vite app → nginx serves dist/
│   └── site/              # React + Vite application deployed to GitHub Pages
├── docbase/               # all documentation (markdown → GitHub Wiki)
│   ├── TOCTREE.md         # index of every doc (also drives wiki Home/_Sidebar)
│   └── docs/*.md          # charter, SRS, architecture, API, ERD, ...
└── .github/workflows/     # CI/CD pipeline
```

## Workflow

Every change follows seven steps (see `AGENTS.md`): capture the requirement → plan & track (manage issues, labels, milestones as project manager) → implement in `codebase/` → document in `docbase/` → update `CHANGELOG.md` → commit to `dev-001` → CI/CD runs.

### Workflow steps (PlantUML)

```plantuml
@startuml
!theme plain
skinparam actorStyle awesome

actor User as U
participant "codebase/" as C
participant "docbase/" as D
participant "CHANGELOG.md" as CL
participant "dev-001" as G
participant "CI/CD" as CI

U -> C : 1. Capture requirement
U -> G : 2. Plan & track (backlog, items, tasklist)
U -> C : 3. Implement
U -> D : 4. Document
U -> CL : 5. Update changelog
U -> G : 6. Commit + push
G -> CI : 7. Pipeline runs
CI -> CI : release → fast_checks → promote
CI -> CI : → security_checks → pages + wiki
@enduml
```

## Branch model

```
dev-001 → dev → main → GitHub Pages (app) + GitHub Wiki (docs)
```

- Work only on `dev-001`.
- `dev-001 → dev`: fast checks (compose validation, image build, lint).
- `dev → main`: quality gates — CodeQL (SAST) + SonarQube Cloud (quality gate), fail closed.
- `main → GitHub Pages`: build and deploy the React + Vite application (`codebase/site/`).
- `main → GitHub Wiki`: sync `docbase/` markdown to the repository's wiki (runs in parallel with `pages`).

Promotion is automated; never push directly to `dev` or `main`.

## Versioning

Strict `major.minor.patch`. The `release` job derives the bump from conventional commit subjects:

- `feat!:` or `BREAKING CHANGE:` → major
- `feat:` → minor
- everything else → patch

## Prerequisites

Configure secrets, notification settings, and Pages from a local `.env` (auto-config):

```bash
cp .env.example .env          # fill in tokens + notification values
./scripts/configure-secrets.sh
```

What you need before filling in `.env`:

- **`GIT_PUSH_TOKEN`** — GitHub PAT with `repo` + `workflow` scopes (pushes release commits).
- **`PROMOTE_TOKEN`** — GitHub PAT with `repo` + `workflow` scopes (PRs created by `GITHUB_TOKEN` don't trigger checks, so promotion needs a PAT; also reused to push `docbase/` to the GitHub Wiki).
- **`SONAR_TOKEN`** — SonarQube Cloud token (SonarCloud → My Account → Security). Optional.
- **`NOTIFICATION_ADDRESS`** — Email recipient for deployment notifications.
- **`NOTIFICATION_HEADER`** — Email subject header (e.g. `GitHub - [HKO] opencode-workflow-demo`).
- **`NOTIFICATION_ACTIVE`** — `true` to enable, `false` to disable.
- GitHub Pages source set to **GitHub Actions** (the script does this; or set it manually under Settings → Pages).
- `dev-001` registered as a deployment branch in **Settings → Environments → github-pages** (the script does this too).
- GitHub Wiki initialized once: open **{repo}/wiki** in the browser and create the first page. Until then the `wiki` job warns and skips (non-blocking); pages deployment is unaffected.

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
4. Set `base` in `codebase/site/vite.config.ts` to `/<your-repo>/`.
5. Update `sonar-project.properties` (`sonar.organization`, `sonar.projectKey`, `sonar.projectName`).
6. Configure the secrets and Pages source above.
