# CI/CD Pipeline

## Branch model

```
dev-001 → dev → main → GitHub Pages (app) + GitHub Wiki (docs)
```

Working branch is always `dev-001`. Promotion is automated by GitHub Actions; never push directly to `dev` or `main`.

### Pipeline overview (Mermaid)

```mermaid
flowchart LR
  subgraph dev-001["dev-001 (working branch)"]
    PUSH["push to dev-001"]
    RELEASE["release\nbump version + CHANGELOG"]
    FAST["fast_checks\ncompose • build • lint"]
    PROMOTE["promote\nopen PRs + merge on gate pass"]
  end
  subgraph dev["dev (staging)"]
    PR1["PR: dev-001 → dev"]
  end
  subgraph main["main (release)"]
    PR2["PR: dev → main"]
    SEC["security_checks\nCodeQL + SonarQube"]
  end
  subgraph pages["GitHub Pages"]
    DEPLOY["pages\nbuild + deploy Vite app"]
  end
  subgraph wiki["GitHub Wiki"]
    WIKI["wiki\nsync docbase/ markdown"]
  end

  PUSH --> RELEASE --> FAST --> PROMOTE
  PROMOTE -->|create PR| PR1 -->|gate: Fast Checks| PROMOTE
  PROMOTE -->|merge| PR2 -->|gate: Security & Quality| SEC
  SEC -->|merge to main| DEPLOY
  SEC -->|merge to main| WIKI
```

### Promotion sequence (Mermaid)

```mermaid
sequenceDiagram
  participant dev001 as dev-001
  participant R as release job
  participant F as fast_checks
  participant P as promote job
  participant GH as GitHub PRs
  participant S as security_checks
  participant PG as pages job
  participant WK as wiki job

  dev001->>R: push (conventional commit)
  R->>R: bump version, update CHANGELOG
  R->>dev001: push release commit
  R->>F: (needs release)
  F->>F: validate compose, build, lint
  F->>P: (needs fast_checks)
  P->>GH: create PR dev-001 → dev
  GH-->>GH: Fast Checks gate runs
  P->>GH: merge PR (gate passed)
  P->>GH: create PR dev → main
  GH-->>GH: Security & Quality Gate runs
  P->>GH: merge PR (gate passed)
  GH->>PG: push to main triggers pages
  PG->>PG: build Vite app, deploy to Pages
  GH->>WK: push to main triggers wiki
  WK->>WK: sync docbase/ to GitHub Wiki
```

## Stages

| Hop | Workflow job | Purpose |
| --- | --- | --- |
| `dev-001` push | `release` | Bump version (`major.minor.patch`) from conventional commits and update `CHANGELOG.md`. |
| `dev-001` → `dev` | `fast_checks` | Validate compose, build the image, lint. Gates the promotion PR. |
| `dev` → `main` | `security_checks` | CodeQL (SAST) + SonarQube Cloud (SCA + quality gate). Fails closed on findings. The SonarQube Quality Gate check exits 1 on ERROR status (fail-closed) when `SONAR_TOKEN` is configured; skipped with a notice when absent. Third-party actions are pinned to full commit SHAs. |
| `main` → Pages | `pages` | Build the React + Vite application (`codebase/site/`) and deploy to GitHub Pages. |
| `main` → Wiki | `wiki` | Sync `docbase/` markdown to the GitHub Wiki. Runs in parallel with `pages`. Non-blocking: warns and skips if the wiki is not yet initialized (needs one-time UI page creation). |

## Versioning

Versions are strict `major.minor.patch`. The `release` job parses commit subjects since the last `chore(release):` commit:

- `feat:` / `feat!:` → minor (or major if breaking)
- `fix:` → patch
- `BREAKING CHANGE:` in a body → major
- anything else → patch

### Version bump decision (Mermaid)

```mermaid
flowchart TD
  START([Parse commits since last release]) --> CHECK_BREAK{BREAKING CHANGE
  or feat!?}
  CHECK_BREAK -->|yes| MAJOR[major: X+1.0.0]
  CHECK_BREAK -->|no| CHECK_FEAT{any feat: ?}
  CHECK_FEAT -->|yes| MINOR[minor: X.Y+1.0]
  CHECK_FEAT -->|no| PATCH[patch: X.Y.Z+1]
  MAJOR --> WRITE[Prepend entry to CHANGELOG.md]
  MINOR --> WRITE
  PATCH --> WRITE
  WRITE --> COMMIT["chore(release): X.Y.Z"]
  COMMIT --> PUSH[push to dev-001]
```

## Required secrets

| Secret | Used by | Description |
| --- | --- | --- |
| `GIT_PUSH_TOKEN` | release | PAT for pushing release commits. Scopes: `repo`, `workflow`. |
| `PROMOTE_TOKEN` | promote, wiki | PAT that creates/merges promotion PRs (GITHUB_TOKEN PRs don't trigger checks) and pushes docbase/ to the GitHub Wiki. Scopes: `repo`, `workflow`. |
| `SONAR_TOKEN` | security_checks | SonarQube Cloud analysis token. Optional — when absent, runs CodeQL-only SAST. |
| `NOTIFICATION_ADDRESS` | pages | Recipient email for deployment notifications. |
| `NOTIFICATION_HEADER` | pages | Email subject header for deployment notifications. |
| `NOTIFICATION_ACTIVE` | pages | `"true"` to enable notifications, `"false"` to disable. |

## Repository settings

- Enable GitHub Pages: **Settings → Pages → Source: GitHub Actions**.
- Add `dev-001` and `main` as deployment branches in **Settings → Environments → github-pages**.
- Enable the GitHub Wiki feature: **Settings → General → Features → Wikis** (the `configure-secrets.sh` script does this).
- Initialize the GitHub Wiki (one-time): open **{repo}/wiki** in the browser and create the first page. GitHub does not create the `.wiki.git` repo until this is done. The `wiki` job warns and skips (non-blocking) until then.
- Protect `dev` and `main`; require the matching status checks before merge.

### Deployment topology (PlantUML)

```plantuml
@startuml
!theme plain
skinparam componentStyle rectangle

cloud "GitHub" as GH {
  rectangle "dev-001\n(working branch)" as dev001
  rectangle "dev\n(staging)" as dev
  rectangle "main\n(release)" as main
  rectangle "GitHub Pages\n(Vite app)" as pages
  rectangle "GitHub Wiki\n(docbase markdown)" as wiki
}

rectangle "Runner" as runner {
  rectangle "release job" as rls
  rectangle "fast_checks job" as fc
  rectangle "promote job" as prom
  rectangle "security_checks job" as sec
  rectangle "pages job" as pg
  rectangle "wiki job" as wk
}

dev001 --> rls : push
rls --> dev001 : release commit
rls --> fc : needs release
fc --> prom : needs fast_checks
prom --> dev : merge PR (gate: Fast Checks)
dev --> sec : PR trigger
sec --> main : merge PR (gate: Security & Quality)
main --> pg : push trigger
pg --> pages : deploy
main --> wk : push trigger
wk --> wiki : sync
@enduml
```
