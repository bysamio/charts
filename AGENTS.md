# AGENTS.md

## Repository Overview

BySamio Helm charts for Kubernetes. Ships hardened, non-root container images via `ghcr.io/bysamio/`.

**Charts:** `wordpress/`, `keycloak/`, `postgresql/`, `mariadb/`, `memcached/`
**Registry:** `oci://ghcr.io/bysamio/charts`
**CI:** `.github/workflows/release-charts.yml` — packages and pushes charts on merge to `main`

## Project Structure

```
<chart>/
  Chart.yaml          # Chart metadata, version, appVersion, dependencies
  values.yaml         # Default values (source of truth for all params)
  README.md           # User-facing docs with param tables and upgrade notes
  templates/
    _helpers.tpl      # All template helpers/functions
    statefulset.yaml  # or deployment.yaml — main workload
    *.yaml            # Services, ingress, secrets, configmaps, etc.
    NOTES.txt         # Post-install message
scripts/              # Pre-commit hook scripts (lint, template, deps, test)
```

## Key Conventions

- **Images:** All charts use `ghcr.io/bysamio/<app>` images. Keycloak has two variants: flexible (default, auto-builds at startup) and optimized (tag contains `-optimized`, pre-built).
- **Security:** Non-root (UID 1001), `readOnlyRootFilesystem` where possible, network policies default on. Keycloak auto-adjusts `readOnlyRootFilesystem` based on image variant.
- **Passwords:** Always use `secretKeyRef` env vars. Never use `_FILE` suffix env vars (that's a Bitnami convention, not supported by upstream images).
- **Helpers:** All reusable logic goes in `_helpers.tpl`. Use `include` not `template`. Helpers handle image resolution, secret names, security contexts, and feature detection.
- **Version bumps:** Patch for fixes, minor for new features/non-breaking behavior changes, major for breaking changes. Update `Chart.yaml` version, add upgrade notes to `README.md` under `## Upgrading`.

## Development Workflow

### Prerequisites
- `helm` (3.8+), `kubectl`, `pre-commit`, a Kubernetes cluster (minikube)

### Pre-commit Hooks
All commits run 10 hooks automatically (configured in `.pre-commit-config.yaml`):
- File checks: trailing whitespace, end-of-file, YAML syntax, large files, merge/case conflicts
- Helm: lint, template render, dependency check, changed-chart tests

Never skip hooks (`--no-verify`). If a hook fails, fix the issue.

### Testing Changes
1. Edit chart files
2. Verify template rendering: `helm template test <chart>/`
3. Deploy to minikube: `helm upgrade --install <name> <chart>/ --set <values> --wait --timeout 5m`
4. Check logs: `kubectl logs <pod> -c <container> --tail=20`
5. Clean up: `helm uninstall <name> && kubectl delete pvc --all`

### Committing
```bash
git add <chart>/ && git commit -m "<type>(<chart>): <description>"
```
Commit types: `fix`, `feat`, `docs`, `refactor`, `chore`

## Chart-Specific Notes

### Keycloak
- `keycloak.isOptimizedImage` helper detects optimized vs flexible by checking for `-optimized` in the image tag
- `keycloak.hostname` helper resolves hostname: `values.hostname` > `ingress.hostname` > empty (Keycloak fails if `hostnameStrict=true` without a hostname — this is intentional)
- `keycloak.containerSecurityContext` forces `readOnlyRootFilesystem=false` for flexible images
- Init container `prepare-write-dirs` copies `/opt/keycloak/lib` to emptyDir for writable overlay (flexible only)
- `keycloakConfigCli` uses `adorsys/keycloak-config-cli` (upstream), not Bitnami's fork

### PostgreSQL
- `auth.username`/`auth.password` create an **additional** user, not a replacement for the `postgres` superuser
- Init script in `create-user-configmap.yaml` runs `CREATE USER` + `GRANT` via psql
- Subchart dependency for Keycloak is pinned in `keycloak/Chart.yaml`

### WordPress
- Depends on `mariadb` and `memcached` subcharts
- PHP config via `php-configmap.yaml`
