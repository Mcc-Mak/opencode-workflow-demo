# Architecture

## Overview

This repository is a reusable template for OpenCode projects. It separates **implementation** (`codebase/`) from **documentation** (`docbase/`) and **CI/CD infrastructure** (`.github/`). The pipeline progressively promotes code through three branch gates before deploying a Vite application to GitHub Pages and documentation to the GitHub Wiki.

## System structure (Mermaid)

```mermaid
flowchart TB
  subgraph repo["Repository"]
    subgraph codebase["codebase/ (project-specific)"]
      ENV[".env.example"]
      DC["docker-compose.yml"]
      DF["Dockerfile (multi-stage)"]
      APP["site/ (React + Vite app)"]
    end
    subgraph docbase["docbase/ (documentation, markdown only)"]
      DOCS["docs/*.md (15 docs)"]
      TOC["TOCTREE.md"]
    end
    subgraph cicd[".github/workflows/"]
      WF["ci-cd.yml (6 jobs)"]
    end
    AGENTS["AGENTS.md"]
    CL["CHANGELOG.md"]
  end

  ENV --> DC
  DC --> DF
  DF --> APP
  TOC --> DOCS
  WF -->|promotes| repo
```

## Components (PlantUML)

```plantuml
@startuml
!theme plain
skinparam componentStyle rectangle

package "codebase/" {
  [Dockerfile] as df
  [docker-compose.yml] as dc
  [.env.example] as env
  [site/ (Vite app)] as app
}

package "docbase/" {
  [docs/*.md] as docs
  [TOCTREE.md] as toc
}

package ".github/workflows/" {
  [ci-cd.yml] as wf
}

[AGENTS.md] as agents
[CHANGELOG.md] as cl

env --> dc : ports + NIC
dc --> df : build
df --> app : npm build → nginx serve
toc --> docs : index
wf --> cl : version bump
@enduml
```

- **Service** — containerised application defined by the multi-stage `Dockerfile` (a `node` stage builds the Vite app, an `nginx` stage serves `dist/`) + `docker-compose.yml`; ports and NIC come from `.env`.
- **App site** — React + Vite SPA in `codebase/site/`, deployed to GitHub Pages. The container and Pages ship an identical `dist/` artifact.
- **Documentation** — markdown-only `docbase/`, published to the GitHub Wiki by the `wiki` job.
- **Pipeline** — six-job workflow (`release → fast_checks → promote → security_checks → pages + wiki`) that progressively promotes code from `dev-001` to GitHub Pages (app) and the GitHub Wiki (docs).

## CI/CD data flow (Mermaid)

```mermaid
flowchart LR
  A["dev-001 push"] --> B["release\nversion bump"]
  B --> C["fast_checks\ncompose + build + lint"]
  C --> D["promote\nPR dev-001→dev"]
  D -->|gate: Fast Checks| E["merge to dev"]
  E --> F["PR dev→main"]
  F -->|gate: Security & Quality| G["merge to main"]
  G --> H["pages\nbuild + deploy"]
  G --> W["wiki\nsync docbase/"]
  H --> I["GitHub Pages (app)"]
  W --> J["GitHub Wiki (docs)"]
```

## Deployment

The system deploys in three ways:

1. **Container** — `docker compose up --build` from `codebase/`; the multi-stage `Dockerfile` builds the Vite app and serves `dist/` from nginx, binding to the host port and NIC defined in `.env`.
2. **Application** — GitHub Actions builds the Vite app in `codebase/site/` and deploys the static artifact to GitHub Pages on every push to `main`. Identical `dist/` to the container.
3. **Documentation** — GitHub Actions syncs `docbase/` markdown to the GitHub Wiki on every push to `main` (parallel with Pages).

### Deployment flow (PlantUML)

```plantuml
@startuml
!theme plain

artifact "Docker Image" as image
folder "Container" as container
cloud "GitHub Pages" as pages
cloud "GitHub Wiki" as wiki
folder "codebase/site/" as source
folder "docbase/" as docs

source --> image : build (Dockerfile)
image --> container : docker compose up
source --> pages : build (Vite) + deploy (Actions)
docs --> wiki : sync (Actions)

note right of container
  Binds to PORT and NIC
  from .env
end note

note right of pages
  base: /opencode-workflow-demo/
  Triggered on push to main
end note

note right of wiki
  Reuses PROMOTE_TOKEN
  Bootstraps on first run
end note
@enduml
```
