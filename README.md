# BySam Helm Charts

Official Helm charts repository for WordPress, MariaDB, and Memcached deployments.

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/bysamio-charts)](https://artifacthub.io/packages/search?repo=bysamio-charts)

## 🚀 Quick Start

### OCI Registry (Recommended for Helm 3.8+)

Install charts directly from GitHub Container Registry:

```bash
helm install my-wordpress oci://ghcr.io/bysamio/charts/wordpress --version 1.0.4
helm install my-mariadb oci://ghcr.io/bysamio/charts/mariadb --version 1.0.2
helm install my-memcached oci://ghcr.io/bysamio/charts/memcached --version 1.0.1
```

### Traditional Helm Repository

```bash
helm repo add bysamio https://bysamio.github.io/charts/
helm repo update
helm install my-wordpress bysamio/wordpress
```

## 📦 Available Charts

| Chart | Description | Version | App Version |
|-------|-------------|---------|-------------|
| [wordpress](./wordpress/) | WordPress CMS with auto-installation | 1.0.4 | 6.8.2 |
| [mariadb](./mariadb/) | MariaDB database | 1.0.2 | 12.0.2 |
| [memcached](./memcached/) | Memcached caching system | 1.0.1 | 1.6.24 |

## 📖 Documentation

- [Setup Guide](./ARTIFACT_HUB_SETUP.md) - Complete setup and configuration guide
- [WordPress Chart](./wordpress/README.md) - WordPress chart documentation

## 🔗 Links

- **Artifact Hub**: https://artifacthub.io/packages/search?repo=bysamio-charts
- **GitHub Repository**: https://github.com/bysamio/charts
- **Helm Repository**: https://bysamio.github.io/charts/
- **OCI Registry**: `oci://ghcr.io/bysamio/charts`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

See individual chart directories for licensing information.

## 👤 Maintainer

**BySam Charts**
- Email: admin@bysam.io
- GitHub: [@bysamio](https://github.com/bysamio)

A collection of production-ready Helm charts for deploying WordPress with MariaDB and Memcached using official Docker images.

## Overview

The BySam chart collection provides a complete WordPress stack with the following components:

- **WordPress**: Official WordPress 6.8.2 with Apache
- **MariaDB**: Official MariaDB 12.0.2 database
- **Memcached**: Official Memcached 1.6.24 for caching

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

### WordPress (`bysam/wordpress`)

- **Base Image**: `wordpress:6.8.2-apache`
- **Features**: Full WordPress functionality with Apache, PHP, and MySQL/MariaDB support
- **Security Context**: Uses standard `www-data` user (UID 33)
- **Configuration**: Standard WordPress environment variables

### MariaDB (`bysam/mariadb`)

- **Base Image**: `mariadb:12.0.2`
- **Features**: Full MariaDB functionality with replication support
- **Security Context**: Uses standard `mysql` user (UID 999)
- **Configuration**: Standard MariaDB environment variables

### Memcached (`bysam/memcached`)

- **Base Image**: `memcached:1.6.24-alpine`
- **Features**: High-performance distributed memory caching
- **Security Context**: Uses standard `memcache` user (UID 11211)
- **Configuration**: Standard Memcached command-line options

## Usage

### Install WordPress with MariaDB

```bash
# Add the local chart repository
helm repo add bysam file:///path/to/charts/bysam

# Install WordPress with dependencies
helm install my-wordpress bysam/wordpress \\
  --set mariadb.auth.rootPassword=secretpassword \\
  --set mariadb.auth.password=wordpresspassword \\
  --set wordpressPassword=adminpassword
```

### Custom Values Example

```yaml
# values.yaml
image:
  registry: docker.io
  repository: wordpress
  tag: "6.8.2-apache"

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
helm install my-wp bysam/wordpress -f values.yaml
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
└── memcached/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
```

## Development

To work with these charts locally:

```bash
# Update dependencies
cd bysam/wordpress
helm dependency update

# Test template rendering
helm template my-test . -f values.yaml

# Dry run installation
helm install --dry-run --debug my-test .
```

## Support

These charts are maintained as part of the BySam project. For issues or questions:

- **GitHub Issues**: [https://github.com/bysamio/charts/issues](https://github.com/bysamio/charts/issues)
- **Email**: <admin@bysam.io>

## License

These charts are licensed under the Apache 2.0 License, same as the original Bitnami charts they're based on.
