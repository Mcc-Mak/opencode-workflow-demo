# Quick Start

## Prerequisites

- Docker
- (Optional) `jq` for pretty JSON output

## Run locally

```mermaid
flowchart LR
  A["cp .env.example .env"] --> B["docker compose up --build"]
  B --> C["open http://127.0.0.1:8080"]
```

1. Copy the environment file and adjust values:

   ```bash
   cp codebase/.env.example codebase/.env
   ```

2. Build and start the service:

   ```bash
   docker compose --env-file codebase/.env --project-directory codebase up --build
   ```

3. Open <http://127.0.0.1:8080> in a browser.

## Stop

```bash
docker compose --env-file codebase/.env --project-directory codebase down
```

## CI/CD setup (PlantUML)

```plantuml
@startuml
!theme plain
skinparam actorStyle awesome

actor Developer as dev
participant "git push" as git
participant "release" as rls
participant "fast_checks" as fc
participant "promote" as prom
participant "security_checks" as sec
participant "pages" as pg

dev -> git : commit to dev-001
git -> rls : push
rls -> rls : bump version + CHANGELOG
rls -> fc : trigger
fc -> fc : compose + build + lint
fc -> prom : pass
prom -> prom : PR dev-001 → dev (gate: Fast Checks)
prom -> prom : PR dev → main (gate: Security & Quality)
prom -> pg : merge to main
pg -> pg : build Vite site
pg -> dev : deploy to GitHub Pages
@enduml
```
