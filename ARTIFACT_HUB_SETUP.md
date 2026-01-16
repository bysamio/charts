# Artifact Hub Setup Guide

This repository is configured to automatically build, package, and publish Helm charts to both Artifact Hub (via GitHub Pages) and GitHub Container Registry (OCI).

## Overview

The GitHub workflow automatically:
1. Builds and validates the charts (wordpress, mariadb, memcached)
2. Packages them using Helm
3. **Publishes to GitHub Container Registry (OCI)** at `ghcr.io/bysamio/charts`
4. Publishes to GitHub Releases
5. Updates the Helm repository index on GitHub Pages
6. Copies the `artifacthub-repo.yml` to GitHub Pages for Artifact Hub verification

## Distribution Methods

Your charts are available through **two methods**:

### 🆕 Method 1: OCI Registry (Modern, Recommended for Helm 3.8+)

Install directly from GitHub Container Registry:

```bash
# Install wordpress
helm install my-wordpress oci://ghcr.io/bysamio/charts/wordpress --version 1.0.26

# Install mariadb
helm install my-mariadb oci://ghcr.io/bysamio/charts/mariadb --version 1.0.2

# Install memcached
helm install my-memcached oci://ghcr.io/bysamio/charts/memcached --version 1.0.1
```

**Advantages:**
- No need to add repository
- Faster and more secure
- Modern OCI standard
- Same infrastructure as container images

### 📦 Method 2: Traditional Helm Repository (GitHub Pages)

Add the repository and install:

```bash
# Add repository
helm repo add bysamio https://bysamio.github.io/charts/
helm repo update

# Install charts
helm install my-wordpress bysamio/wordpress
helm install my-mariadb bysamio/mariadb
helm install my-memcached bysamio/memcached
```

**Advantages:**
- Compatible with older Helm versions (2.x, 3.0-3.7)
- Familiar workflow for users
- Better discoverability on Artifact Hub

## Prerequisites

### 1. Enable GitHub Packages (Automatic)

The workflow automatically publishes to GitHub Container Registry (ghcr.io). No additional setup needed! The packages will be visible at:
- https://github.com/bysamio/charts/pkgs/container/charts%2Fwordpress
- https://github.com/bysamio/charts/pkgs/container/charts%2Fmariadb
- https://github.com/bysamio/charts/pkgs/container/charts%2Fmemcached

**To make packages public:**
1. Go to your package settings (link above)
2. Click "Package settings"
3. Scroll to "Danger Zone" → "Change visibility"
4. Select "Public"

### 2. Enable GitHub Pages

1. Go to your repository settings: https://github.com/bysamio/charts/settings/pages
2. Under "Source", select **gh-pages** branch
3. Select **/ (root)** folder
4. Click Save

Your charts will be available at: `https://bysamio.github.io/charts/`

### 3. Register on Artifact Hub

1. Go to https://artifacthub.io/
2. Sign in with your GitHub account (bysamio)
3. Click on "Control Panel" in the user menu
4. Click "Add repository"
5. Fill in the details:
   - **Name**: BySam Charts (or your preferred name)
   - **Display name**: BySam Charts
   - **URL**: `https://bysamio.github.io/charts/`
   - **Type**: Helm charts
   - **Repository ID**: `bysamio-charts` (matches artifacthub-repo.yml)
6. Click "Add"

## Files Created/Modified

### `artifacthub-repo.yml`
This file provides metadata for Artifact Hub to verify repository ownership and display information about the repository.

### `.github/workflows/release-charts.yml`
Enhanced workflow that:
- Triggers on changes to chart directories or the artifacthub-repo.yml file
- Lints all charts before packaging
- Packages charts once and uses them for both publishing methods
- **Pushes charts to GitHub Container Registry (OCI)** at `ghcr.io/bysamio/charts`
- Uses `chart-releaser-action` to create GitHub releases
- Updates the `index.yaml` on the gh-pages branch
- Copies `artifacthub-repo.yml` to gh-pages

## How It Works

1. **When you push changes** to wordpress/, mariadb/, or memcached/ directories:
   - The workflow builds chart dependencies
   - Lints each chart for errors
   - Packages the charts
   - **Pushes charts to GitHub Container Registry (ghcr.io/bysamio/charts)**
   - Creates GitHub releases with the chart packages
   - Updates the `index.yaml` on the gh-pages branch
   - Copies `artifacthub-repo.yml` to gh-pages

2. **Artifact Hub automatically syncs** with your GitHub Pages repository:
   - Reads the `index.yaml` from your GitHub Pages
   - Reads the `artifacthub-repo.yml` for verification
   - Updates chart listings every few hours

3. **GitHub Container Registry** hosts your OCI charts:
   - Charts are available at `oci://ghcr.io/bysamio/charts/<chart-name>`
   - Can be made public or kept private
   - Supports authentication and versioning

## Using the Charts

### OCI Method (Modern)

```bash
# Pull and inspect
helm pull oci://ghcr.io/bysamio/charts/wordpress --version 1.0.18
helm show values oci://ghcr.io/bysamio/charts/wordpress --version 1.0.18

# Install
helm install my-wordpress oci://ghcr.io/bysamio/charts/wordpress --version 1.0.26

# Upgrade
helm upgrade my-wordpress oci://ghcr.io/bysamio/charts/wordpress --version 1.0.26
```

### Traditional Repository Method

```bash
# Add repo
helm repo add bysamio https://bysamio.github.io/charts/
helm repo update

# Search
helm search repo bysamio

# Install
helm install my-wordpress bysamio/wordpress --version 1.0.26

# Upgrade
helm upgrade my-wordpress bysamio/wordpress --version 1.0.26
```

## Viewing on Artifact Hub

Once registered, your charts will be available at:
- https://artifacthub.io/packages/helm/bysamio-charts/wordpress
- https://artifacthub.io/packages/helm/bysamio-charts/mariadb
- https://artifacthub.io/packages/helm/bysamio-charts/memcached

## Triggering the Workflow

You can trigger the workflow:
1. **Automatically**: Push changes to chart directories
2. **Manually**: Go to Actions tab → Release Helm Charts → Run workflow

## Troubleshooting

### Charts not appearing on Artifact Hub
- Verify GitHub Pages is enabled and serving from gh-pages branch
- Check that the workflow completed successfully
- Ensure `artifacthub-repo.yml` exists in the gh-pages branch
- Wait a few hours for Artifact Hub to sync (or click "Force sync" in Artifact Hub)

### OCI charts not accessible
- Check that packages are set to "Public" in GitHub package settings
- Verify the workflow completed the "Push charts to OCI registry" step
- Ensure you're using Helm 3.8.0 or later: `helm version`

### Authentication issues with OCI registry
For private packages, authenticate first:
```bash
echo $GITHUB_TOKEN | helm registry login ghcr.io -u USERNAME --password-stdin
```

### Workflow fails
- Check the Actions tab for error logs
- Ensure all Chart.yaml files have proper version numbers
- Verify chart dependencies are correctly specified
- Make sure the `packages: write` permission is set in the workflow

## Chart Versioning

To release a new version:
1. Update the `version` field in the chart's `Chart.yaml`
2. Update the `appVersion` if the application version changed
3. Commit and push to main branch
4. The workflow will automatically create a new release

## Recent Changes

### WordPress Chart v1.0.26

**Key Improvements:**
- **Fixed CAP_NET_BIND_SERVICE capability**: Apache can now bind to port 80 even with `drop: ALL` capabilities
- Added `NET_BIND_SERVICE` capability to allow privileged port binding while maintaining security

**Technical Details:**
- Added `capabilities.add: ["NET_BIND_SERVICE"]` to containerSecurityContext
- This allows Apache to bind to port 80 even when other capabilities are dropped

### WordPress Chart v1.0.25

**Key Improvements:**
- **Fixed default security context for official WordPress image**: Chart now works out-of-the-box with the official `wordpress:apache` image
- Root user is now allowed by default so Apache can bind to port 80 (Apache drops to www-data after binding)
- Users no longer need to override `containerSecurityContext` in their values

**Technical Details:**
- Changed `containerSecurityContext.runAsUser` from `33` to `0`
- Changed `containerSecurityContext.runAsNonRoot` from `true` to `false`
- Added clear documentation in values.yaml explaining Apache's privilege model

### WordPress Chart v1.0.24

**Key Improvements:**
- **Fixed MariaDB existingSecret support**: WordPress deployment now correctly uses `mariadb.auth.existingSecret` for database password instead of always looking for `{release-name}-mariadb` secret
- Both WordPress container and installer sidecar now respect the existingSecret configuration

**Technical Details:**
- Fixed WORDPRESS_DB_PASSWORD secretKeyRef to check for mariadb.auth.existingSecret first
- Uses mariadb.auth.password as the key name when existingSecret is set

### WordPress Chart v1.0.23

**Key Improvements:**
- **Fixed NetworkPolicy**: Resolved empty `policyTypes` issue when using `extraIngress`/`extraEgress` rules with `allowExternal: false`
- **Fixed PodDisruptionBudget**: Template now correctly uses only one of `minAvailable` or `maxUnavailable` (Kubernetes requirement)
- **Fixed ServiceMonitor**: Added missing `selector` and `namespaceSelector` for proper Prometheus discovery
- **Improved Secret Key Documentation**: Clarified that `wordpressPassword` is the key name when using `existingSecret`

**Technical Details:**
- NetworkPolicy now adds policyTypes based on presence of rules, not just the allow flags
- PDB prioritizes `minAvailable` if both values are set
- ServiceMonitor uses WordPress selectorLabels by default
- Tested on Minikube with full deployment verification

### WordPress Chart v1.0.22

**Key Improvements:**
- **Simplified Custom Entrypoint**: Replaced complex entrypoint script with a cleaner, more maintainable version
- **Better Error Logging**: PHP and Apache errors now log to stderr/stdout, making them visible via `kubectl logs`
- **Improved Reliability**: Direct execution of official WordPress entrypoint ensures proper initialization
- **Enhanced Configuration**: Apache VirtualHost includes `ServerName` directive to suppress warnings
- **Non-Privileged Ports**: Full support for running on ports 8080/8443 without `NET_BIND_SERVICE` capability

**Technical Details:**
- Uses simplified `custom-entrypoint.sh` that execs the official WordPress entrypoint
- Apache configs (ports.conf, 000-default.conf) mounted via ConfigMap
- PHP error logging configured to `/proc/self/fd/2` (stderr)
- Apache error/custom logs configured to `/proc/self/fd/2` and `/proc/self/fd/1` respectively

## Additional Resources

- [Artifact Hub Documentation](https://artifacthub.io/docs/)
- [Helm Chart Releaser Action](https://github.com/helm/chart-releaser-action)
- [Helm Documentation](https://helm.sh/docs/)
