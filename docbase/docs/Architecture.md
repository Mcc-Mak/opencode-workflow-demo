# Architecture

## Overview

This repository is a reusable template for OpenCode projects. It separates **implementation** (`codebase/`) from **documentation** (`docbase/`) and **CI/CD infrastructure** (`.github/`). The pipeline progressively promotes code through three branch gates before deploying a Vite-powered docs site to GitHub Pages.

## System structure (Mermaid)

```mermaid
flowchart TB
  subgraph repo["Repository"]
    subgraph codebase["codebase/ (project-specific)"]
      ENV[".env.example"]
      DC["docker-compose.yml"]
      DF["Dockerfile"]
      APP["html/ (app content)"]
    end
    subgraph docbase["docbase/ (documentation)"]
      DOCS["docs/*.md (15 docs)"]
      SITE["site/ (React + Vite)"]
      TOC["TOCTREE.md"]
    end
    subgraph cicd[".github/workflows/"]
      WF["ci-cd.yml (5 jobs)"]
    end
    AGENTS["AGENTS.md"]
    CL["CHANGELOG.md"]
  end

  ENV --> DC
  DC --> DF
  DF --> APP
  TOC --> DOCS
  DOCS --> SITE
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
  [html/] as app
}

package "docbase/" {
  [docs/*.md] as docs
  [site/ (Vite)] as site
  [TOCTREE.md] as toc
}

package ".github/workflows/" {
  [ci-cd.yml] as wf
}

[AGENTS.md] as agents
[CHANGELOG.md] as cl

env --> dc : ports + NIC
dc --> df : build
df --> app : serve
toc --> docs : index
docs --> site : import.meta.glob
wf --> cl : version bump
@enduml
```

- **Service** — containerised application defined by `Dockerfile` + `docker-compose.yml`; ports and NIC come from `.env`.
- **Docs site** — React + Vite SPA that imports all `docs/*.md` at build time via `import.meta.glob` and renders them with `react-markdown`.
- **Pipeline** — five-job workflow (`release → fast_checks → promote → security_checks → pages`) that progressively promotes code from `dev-001` to GitHub Pages.

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
  H --> I["GitHub Pages"]
```

## Deployment

The system deploys in two ways:

1. **Container** — `docker compose up --build` from `codebase/`; binds to the host port and NIC defined in `.env`.
2. **Docs site** — GitHub Actions builds the Vite app in `docbase/site/` and deploys the static artifact to GitHub Pages on every push to `main`.

### Deployment flow (PlantUML)

```plantuml
@startuml
!theme plain

artifact "Docker Image" as image
folder "Container" as container
cloud "GitHub Pages" as pages
folder "docbase/site/" as source

source --> image : build (Dockerfile)
image --> container : docker compose up
source --> pages : build (Vite) + deploy (Actions)

note right of container
  Binds to PORT and NIC
  from .env
end note

note right of pages
  base: /opencode-workflow-demo/
  Triggered on push to main
end note
@enduml
```
