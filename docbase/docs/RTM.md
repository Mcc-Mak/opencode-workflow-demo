# Requirements Traceability Matrix (RTM)

Maps each requirement to its implementation and tests.

| Req ID | Requirement | Implemented in | Verified by |
| --- | --- | --- | --- |
| FR-001 | Seven-step workflow | `AGENTS.md` § Workflow | Manual: confirm `AGENTS.md` lists 7 steps in order. |
| FR-002 | Plan & Track: backlog / items / tasklist | `AGENTS.md` § Workflow step 2 | Manual: confirm step 2 defines three separation-of-concerns. |
| FR-003 | Code/docs separation | `codebase/`, `docbase/` directory structure | Manual: confirm no docs in `codebase/` and no code in `docbase/`. |
| FR-004 | Conventional-commit versioning | `.github/workflows/ci-cd.yml` `release` job | CI: push a `feat:` commit, confirm minor bump in `CHANGELOG.md`. |
| FR-005 | CHANGELOG entry + release commit | `.github/workflows/ci-cd.yml` `release` job | CI: confirm `chore(release): X.Y.Z` commit appears after push. |
| FR-006 | Progressive promotion `dev-001 → dev → main` | `.github/workflows/ci-cd.yml` `promote` job | CI: confirm PRs created and merged in sequence. |
| FR-007 | Fast checks (compose, build, lint) | `.github/workflows/ci-cd.yml` `fast_checks` job | CI: confirm job runs and gates `dev-001 → dev` hop. |
| FR-008 | CodeQL SAST hard gate | `.github/workflows/ci-cd.yml` `security_checks` job | CI: confirm CodeQL runs and blocks `dev → main` on findings. |
| FR-009 | SonarQube Cloud (optional, fail-closed) | `.github/workflows/ci-cd.yml` `security_checks` job | CI: with `SONAR_TOKEN` → runs and fails closed; without → skips with notice. |
| FR-010 | GitHub Pages deployment | `.github/workflows/ci-cd.yml` `pages` job | CI: push to `main`, confirm app live at Pages URL. |
| FR-011 | GitHub Wiki deployment | `.github/workflows/ci-cd.yml` `wiki` job | CI: push to `main`, confirm `docbase/` pages on Wiki. |
| FR-012 | Non-blocking wiki when uninitialized | `.github/workflows/ci-cd.yml` `wiki` job | CI: delete wiki, push to `main`, confirm pipeline succeeds with warning. |
| FR-013 | Secret auto-configuration | `scripts/configure-secrets.sh` | Manual: run script, confirm secrets appear in GitHub Settings → Secrets. |
| FR-014 | Multi-stage Dockerfile | `codebase/Dockerfile` | Manual: `docker compose up --build`, confirm app served on port 8080. |
| NFR-001 | Identical `dist/` (container vs Pages) | `codebase/Dockerfile` + `pages` job | Manual: compare `dist/` hash from container build and Pages artifact. |
| NFR-002 | No secrets committed | `.gitignore` | CI: confirm `.env` is gitignored; scan history for leaked tokens. |
| NFR-003 | PAT-based promotion | `.github/workflows/ci-cd.yml` `promote` job | CI: confirm PRs created by `PROMOTE_TOKEN` trigger gate workflows. |
| NFR-004 | Code/docs separation | Directory structure | Manual: same as FR-003. |
| NFR-005 | Parallel pages + wiki | `.github/workflows/ci-cd.yml` job dependencies | CI: confirm `pages` and `wiki` run concurrently on `main` push. |
| NFR-006 | Git tags for releases | `git tag` | Manual: `git tag -l` confirms annotated tags for each version. |
| NFR-007 | Replaceable `codebase/` | Template structure | Manual: replace `codebase/`, confirm pipeline still works. |
