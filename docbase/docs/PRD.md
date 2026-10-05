# Product Requirements Document (PRD)

## Overview

This repository is a reusable template for OpenCode projects. It bundles a seven-step coding workflow, a progressive GitHub Actions CI/CD pipeline, strict semantic versioning, and a code/docs separation model. Consumers clone the template, replace `codebase/` with their own implementation, configure secrets, and immediately get automated versioning, gated promotion, and parallel app + docs deployment.

## Target users

| Persona | Description | Primary need |
| --- | --- | --- |
| OpenCode developer | An engineer or agent using OpenCode to build a project | A structured workflow and ready-made CI/CD so they can focus on implementation. |
| Project maintainer | Owner of a project created from this template | Automated versioning, traceability, and deployment without manual overhead. |
| CI/CD operator | DevOps engineer responsible for pipeline health | Hard gates, documented secrets, and non-blocking failure modes. |

## Problem statement

Starting a new OpenCode project from scratch requires re-inventing the same infrastructure every time: a branching strategy, a CI/CD pipeline, versioning rules, documentation structure, and deployment configuration. This template eliminates that boilerplate.

## Goals and non-goals

### Goals

- Provide a seven-step workflow that guides every task from requirement to deployment.
- Automate version bumping, changelog generation, and branch-gated promotion.
- Deploy a Vite application to GitHub Pages and documentation to the GitHub Wiki in parallel.
- Keep code and docs strictly separated (`codebase/` vs `docbase/`).

### Non-goals

- Providing project-specific business logic or domain-specific libraries.
- Supporting hosting platforms other than GitHub (Pages, Wiki, Actions).
- Shipping a backend or database layer — the template is a static SPA.

## Features

| ID | Feature | Priority | Notes |
| --- | --- | --- | --- |
| F-001 | Seven-step workflow (`AGENTS.md`) | Must | User Requirement → Plan & Track → Implement → Document → CHANGELOG → Git → CI/CD. |
| F-002 | Progressive CI/CD pipeline | Must | release → fast_checks → promote → security_checks → pages + wiki. |
| F-003 | Conventional-commit versioning | Must | `feat:` → minor, `fix:` → patch, `feat!:` → major. |
| F-004 | CodeQL SAST hard gate | Must | Mandatory on `dev → main` hop. |
| F-005 | SonarQube Cloud quality gate | Should | Fail-closed when `SONAR_TOKEN` configured; skipped with notice when absent. |
| F-006 | GitHub Pages deployment | Must | Vite app build + deploy on `main` push. |
| F-007 | GitHub Wiki deployment | Must | `docbase/` sync on `main` push; non-blocking until wiki is initialized. |
| F-008 | Secret auto-configuration | Should | `scripts/configure-secrets.sh` pushes `.env` values to GitHub encrypted store. |
| F-009 | Multi-stage Dockerfile | Must | `node` stage builds Vite app, `nginx` stage serves `dist/`. |
| F-010 | Git tags for releases | Should | Annotated tag on every `chore(release)` commit. |
| F-011 | Container & supply-chain security hardening | Must | Non-root nginx (`USER nginx` + custom `nginx.conf`), `npm ci --ignore-scripts`, SHA-pinned third-party actions, fail-closed SonarQube QG. |

## User flows

1. Developer clones template → copies `.env.example` → runs `configure-secrets.sh`.
2. Developer works on `dev-001` following the seven-step workflow.
3. Developer pushes `dev-001` → `release` job bumps version + updates CHANGELOG.
4. `fast_checks` validates compose, build, lint → `promote` opens PR `dev-001 → dev`.
5. Fast Checks gate passes → `promote` merges → opens PR `dev → main`.
6. Security & Quality gate passes → `promote` merges to `main`.
7. `pages` deploys the Vite app to GitHub Pages; `wiki` syncs `docbase/` to the Wiki (parallel).

## Success metrics

| Metric | Target |
| --- | --- |
| Time from clone to first deploy | < 10 minutes after secret configuration |
| Manual interventions per release | 0 (fully automated promotion) |
| Container vs Pages artifact drift | None (identical `dist/`) |
| Released versions with git tags | 100% |

## Timeline

| Milestone | Target date |
| --- | --- |
| v0.1.x — CI/CD foundation | 2026-10-05 (delivered) |
| v0.2.0 — Notifications & docs | 2026-10-05 (delivered) |
| v0.3.x — GitHub Pages deploy | 2026-10-05 (delivered) |
| v0.4.x — Pages + Wiki split | 2026-10-05 (delivered) |
| v0.5.x — Workflow hardening | 2026-10-05 (delivered) |

## Open issues

- GitHub project board creation requires a token with `project` + `read:project` scopes (see issue #42).
