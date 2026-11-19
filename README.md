# SamSoft Helm Charts

Official Helm charts repository for CasePack and SamSoft infrastructure charts.

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/sammyeby)](https://artifacthub.io/packages/search?repo=sammyeby)

## 🚀 Quick Start

### OCI Registry (Recommended for Helm 3.8+)

Install charts directly from GitHub Container Registry:

```bash
helm install casepack oci://ghcr.io/sammyeby/charts/casepack --version 0.8.0
helm install casepack-api oci://ghcr.io/sammyeby/charts/casepack-api --version 0.34.0
helm install casepack-spa oci://ghcr.io/sammyeby/charts/casepack-spa --version 0.34.0
helm install my-wordpress oci://ghcr.io/sammyeby/charts/wordpress --version 3.0.1
helm install my-mariadb oci://ghcr.io/sammyeby/charts/mariadb --version 1.0.3
helm install my-memcached oci://ghcr.io/sammyeby/charts/memcached --version 1.0.3
helm install my-keycloak oci://ghcr.io/sammyeby/charts/keycloak --version 1.4.2
helm install gotenberg oci://ghcr.io/sammyeby/charts/gotenberg --version 0.2.1
```

### Traditional Helm Repository

```bash
helm repo add sammyeby https://sammyeby.github.io/charts/
helm repo update
helm install my-wordpress sammyeby/wordpress
```

## 📦 Available Charts

The full, always-current list of charts and their latest versions is published at:

- **Landing page:** <https://sammyeby.github.io/charts/>
- **Artifact Hub:** <https://artifacthub.io/packages/search?repo=sammyeby>

> This list is generated from the published `index.yaml`, so it is intentionally not duplicated here to avoid drift.


## Automation

Application release workflows in `casepack-api` and `casepack-spa` open immediate chart update PRs in this repository after stable image releases. Renovate remains enabled here as a chart-owned safety net and for infrastructure image updates.

After the OCI chart release job succeeds, this repository notifies `sammyeby/argocd` for the CasePack API, SPA, and docs chart versions. Its automation opens or updates a staging PR only for a newer published chart. The CasePack Keycloak values revision moves with the API release. A production PR follows after the exact staging revisions are Synced, Healthy, and pass a public smoke check. The notification needs the GitHub App variable and secret documented in `argocd/docs/release-promotion.md`; publication still succeeds with a warning until those credentials are configured.

| Chart | Image | Renovate behavior |
|-------|-------|-------------------|
| `casepack-api` | `ghcr.io/sammyeby/casepack-api` | Sync chart `version` and `appVersion` to stable app image tags |
| `casepack-spa` | `ghcr.io/sammyeby/casepack-spa` | Sync chart `version` and `appVersion` to stable app image tags |
| `casepack-docs` | `ghcr.io/sammyeby/casepack-docs` | Sync chart `version` and `appVersion` to stable docs image tags |
| `keycloak` | `ghcr.io/sammyeby/keycloak` | Update image tag, sync `appVersion`, bump chart major/minor/patch to match image update type |
| `wordpress` | `ghcr.io/sammyeby/wordpress` | Update image tag, sync `appVersion`, bump chart major/minor/patch to match image update type |
| `postgresql` | `ghcr.io/sammyeby/postgresql` | Update image tag, sync `appVersion`, bump chart major/minor/patch to match image update type |

Snapshot, SHA, and `latest` tags are ignored. PostgreSQL tracking is limited to `*-alpine` image tags.

## 📖 Documentation

- [CasePack Chart](./casepack/README.md) - Full stack chart documentation
- [CasePack API Chart](./casepack-api/README.md) - API chart documentation
- [CasePack SPA Chart](./casepack-spa/README.md) - SPA chart documentation
- [WordPress Chart](./wordpress/README.md) - WordPress chart documentation
- [Keycloak Chart](./keycloak/README.md) - Keycloak chart documentation
- [MinIO Chart](./minio/README.md) - MinIO chart documentation
- [Gotenberg Chart](./gotenberg/README.md) - Gotenberg chart documentation

## 🔗 Links

- **Artifact Hub**: https://artifacthub.io/packages/search?repo=sammyeby
- **GitHub Repository**: https://github.com/sammyeby/charts
- **Helm Repository**: https://sammyeby.github.io/charts/
- **OCI Registry**: `oci://ghcr.io/sammyeby/charts`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

See individual chart directories for licensing information.

## 👤 Maintainer

**SamSoft Technologies**
- GitHub: [@sammyeby](https://github.com/sammyeby)

A collection of production-ready Helm charts for deploying WordPress with MariaDB and Memcached using official Docker images.

## Overview

The SamSoft chart collection provides a complete WordPress stack and identity management solution with the following components:

- **WordPress**: Official WordPress 6.9.0 with Apache
- **MariaDB**: Official MariaDB 12.0.2 database
- **Memcached**: Official Memcached 1.6.24 for caching
- **Keycloak**: SamSoft hardened Keycloak 26.7.4 for Identity and Access Management

## Key Features

- **Auto-Installation**: WordPress automatically completes initial setup when configuration is provided
- **Official Images**: Uses official Docker images instead of Bitnami variants
- **Production Ready**: Includes health checks, security contexts, and resource management
- **Flexible Configuration**: Comprehensive values.yaml for customization
- **Kubernetes Native**: Proper StatefulSets, Deployments, Services, and ConfigMaps
- **Memcached**: Uses `memcached:1.6.24-alpine` (official Memcached image)

## Benefits

1. **No Compatibility Issues**: Official images don't require Bitnami-specific scripts or directory structures
2. **Direct Upstream Support**: Get updates and security patches directly from the official maintainers
3. **Simplified Architecture**: No complex init containers or script compatibility layers
4. **Standard Configuration**: Uses standard environment variables and configurations
5. **Smaller Images**: Official images are often more lightweight than Bitnami equivalents

## Available Charts

### WordPress (`sammyeby/wordpress`)

- **Image**: `ghcr.io/sammyeby/wordpress:7.1.3` (built on `wordpress:7.1.3-apache`)
- **Features**: Full WordPress functionality with Apache, PHP, and MySQL/MariaDB support
- **Security Context**: Non-root `bysamio` user (UID 1001) on port 8080
- **Configuration**: Standard WordPress environment variables

### MariaDB (`sammyeby/mariadb`)

- **Base Image**: `mariadb:12.0.2`
- **Features**: Full MariaDB functionality with replication support
- **Security Context**: Uses standard `mysql` user (UID 999)
- **Configuration**: Standard MariaDB environment variables

### Memcached (`sammyeby/memcached`)

- **Base Image**: `memcached:1.6.24-alpine`
- **Features**: High-performance distributed memory caching
- **Security Context**: Uses standard `memcache` user (UID 11211)
- **Configuration**: Standard Memcached command-line options

### Keycloak (`sammyeby/keycloak`)

- **Base Image**: `ghcr.io/sammyeby/keycloak:26.7.4` (variants: `26.7.4`, `26.7.4-optimized`, `26.7.4-debug`)
- **Features**: Open-source Identity and Access Management (IAM) with SSO, OIDC, OAuth2, SAML support
- **Security Context**: Hardened non-root container (UID 1001 on the Alpine variant, 65532 on the distroless `-optimized`/`-debug` variants)
- **Configuration**: Includes PostgreSQL subchart, metrics, high availability support
- **Use Cases**: Single Sign-On (SSO), user federation, multi-factor authentication, API security

## Usage

### Install WordPress with MariaDB

```bash
# Add the chart repository
helm repo add sammyeby https://sammyeby.github.io/charts/

# Install WordPress with dependencies
helm install my-wordpress sammyeby/wordpress \
  --set mariadb.auth.rootPassword=secretpassword \
  --set mariadb.auth.password=wordpresspassword \
  --set wordpressPassword=adminpassword
```

### Custom Values Example

```yaml
# values.yaml
image:
  registry: docker.io
  repository: wordpress
  tag: "6.9.0-apache"

wordpressUsername: admin
wordpressEmail: admin@example.com
wordpressBlogName: "My Official WordPress"

mariadb:
  enabled: true
  auth:
    rootPassword: myroot123
    database: wordpress
    username: wpuser
    password: wppass123

service:
  type: LoadBalancer

persistence:
  enabled: true
  size: 20Gi
```

### Deploy with Custom Values

```bash
helm install my-wp sammyeby/wordpress -f values.yaml
```

## Migration from Bitnami Charts

If you're migrating from Bitnami charts, the main differences are:

1. **Image Configuration**:

   ```yaml
   # Old (Bitnami)
   image:
     registry: ghcr.io
     repository: sammyeby/bitnami-wordpress

   # New (Official)
   image:
     registry: docker.io
     repository: wordpress
   ```

2. **Security Context**:

   ```yaml
   # Old (Bitnami)
   containerSecurityContext:
     runAsUser: 1001
     runAsGroup: 1001

   # New (Official)
   containerSecurityContext:
     runAsUser: 33    # www-data
     runAsGroup: 33   # www-data
   ```

3. **No Init Containers**: Official images don't need complex init containers for setup

## Chart Structure

```text
/
├── wordpress/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── mariadb/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── memcached/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── keycloak/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── postgresql/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
```

## Development

To work with these charts locally:

```bash
# Update dependencies
cd wordpress
helm dependency update

# Test template rendering
helm template my-test . -f values.yaml

# Dry run installation
helm install --dry-run --debug my-test .
```

## Support

These charts are maintained by SamSoft Technologies. For issues or questions:

- **GitHub Issues**: [https://github.com/sammyeby/charts/issues](https://github.com/sammyeby/charts/issues)

## License

These charts are licensed under the Apache 2.0 License, same as the original Bitnami charts they're based on.
