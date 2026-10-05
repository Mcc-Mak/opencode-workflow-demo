# User Stories

Backlog of user-facing stories. Each story follows: _As a \<role\>, I want \<goal\>, so that \<benefit\>._

## Epic 1: Project setup

### US-001 — Clone and configure

- **As a** developer
- **I want** to create a new repo from this template and configure secrets with a single script
- **So that** I can start coding without manually editing GitHub settings
- **Acceptance criteria:**
  - `cp .env.example .env` + `./scripts/configure-secrets.sh` pushes all secrets and enables Pages + Wiki.
  - The Vite app deploys to GitHub Pages on the first push to `main`.
  - The `docbase/` markdown syncs to the GitHub Wiki on the first push to `main`.

### US-002 — Local development

- **As a** developer
- **I want** to run the project locally with Docker Compose
- **So that** I can verify changes before pushing
- **Acceptance criteria:**
  - `docker compose --env-file codebase/.env --project-directory codebase up --build` starts the app on `http://127.0.0.1:8080`.
  - The container serves the same `dist/` artifact that GitHub Pages deploys.

## Epic 2: Development workflow

### US-003 — Follow the seven-step workflow

- **As an** OpenCode agent
- **I want** a documented seven-step workflow in `AGENTS.md`
- **So that** every task follows a consistent process from requirement to deployment
- **Acceptance criteria:**
  - Steps are followed in order: User Requirement → Plan & Track → Implement → Document → CHANGELOG → Git → CI/CD.
  - Step 2 (Plan & Track) maintains backlog, items, and tasklist as separation of concerns.
  - Documentation and CHANGELOG are never skipped.

### US-004 — Conventional commit versioning

- **As a** developer
- **I want** the pipeline to derive version bumps from my commit messages
- **So that** I don't have to manually track versions
- **Acceptance criteria:**
  - `feat:` → minor bump, `fix:` → patch bump, `feat!:` / `BREAKING CHANGE:` → major bump.
  - The `release` job prepends an entry to `CHANGELOG.md` and tags the commit with `chore(release): X.Y.Z`.

## Epic 3: CI/CD and deployment

### US-005 — Automated promotion

- **As a** CI/CD operator
- **I want** code to progress through branch gates automatically
- **So that** only verified code reaches `main`
- **Acceptance criteria:**
  - `dev-001 → dev` requires fast checks (compose, build, lint).
  - `dev → main` requires CodeQL SAST (hard gate) + SonarQube Cloud (when configured).
  - The `promote` job creates PRs, watches gates, and merges — no manual PR approval needed.

### US-006 — Parallel app + docs deployment

- **As a** project maintainer
- **I want** the app and docs to deploy in parallel on every `main` push
- **So that** consumers always see the latest UI and documentation simultaneously
- **Acceptance criteria:**
  - The `pages` job builds the Vite app and deploys to GitHub Pages.
  - The `wiki` job syncs `docbase/` markdown to the GitHub Wiki.
  - Both jobs run on `main` push and complete independently.

### US-007 — Non-blocking wiki

- **As a** developer
- **I want** the pipeline to succeed even if the GitHub Wiki is not yet initialized
- **So that** a first-time setup doesn't block app deployment
- **Acceptance criteria:**
  - The `wiki` job warns and exits 0 when `.wiki.git` doesn't exist.
  - The `pages` job deploys independently of the wiki job's state.
