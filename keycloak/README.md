# Keycloak Helm Chart

A Helm chart for deploying [Keycloak](https://www.keycloak.org/) using BySamio hardened Docker images.

## Overview

This chart deploys Keycloak, an open-source Identity and Access Management solution, on Kubernetes. It uses BySamio's hardened container images that run as non-root (UID 1001) with security best practices.

## Features

- **Hardened Images**: Uses BySamio's security-hardened Keycloak images
- **Non-root Execution**: Runs as UID 1001 for enhanced security
- **Optimized Image Support**: Automatic detection of pre-built optimized images
- **PostgreSQL Integration**: Bundled PostgreSQL subchart for database
- **High Availability**: Support for clustered deployments with Infinispan caching
- **Metrics & Monitoring**: Prometheus ServiceMonitor and metrics endpoint
- **Security**: Network policies, PodDisruptionBudget, and securityContext configuration
- **Ingress**: Built-in ingress support with TLS

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8+
- PV provisioner support in the underlying infrastructure (for persistence)

## Installing the Chart

### From OCI Registry

```bash
helm install keycloak oci://ghcr.io/bysamio/charts/keycloak \
  --namespace keycloak \
  --create-namespace \
  --set auth.adminPassword=your-admin-password \
  --set postgresql.auth.postgresPassword=your-postgres-password \
  --set postgresql.auth.password=your-keycloak-db-password
```

### From Source

```bash
helm dependency update keycloak
helm install keycloak ./keycloak \
  --namespace keycloak \
  --create-namespace
```

## Configuration

### Image Options

This chart supports two types of BySamio Keycloak images:

| Image Type | Tag Example | Description |
|------------|-------------|-------------|
| Flexible | `26.5.2` | Alpine-based, can auto-build on startup |
| Optimized | `26.5.2-optimized` | Distroless, pre-built, faster startup |

The chart automatically detects optimized images and adjusts configuration accordingly.

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Keycloak image repository | `ghcr.io/bysamio/keycloak` |
| `image.tag` | Keycloak image tag | `26.5.2` |
| `auth.adminUser` | Keycloak admin username | `admin` |
| `auth.adminPassword` | Keycloak admin password | `""` (auto-generated) |
| `production` | Enable production mode | `true` |
| `proxy.enabled` | Enable proxy configuration | `true` |
| `proxy.mode` | Proxy mode (edge, reencrypt, passthrough) | `edge` |
| `postgresql.enabled` | Deploy PostgreSQL subchart | `true` |
| `replicaCount` | Number of Keycloak replicas | `1` |
| `ingress.enabled` | Enable ingress | `false` |

### Database Configuration

By default, the chart deploys PostgreSQL as a subchart. To use an external database:

```yaml
postgresql:
  enabled: false

externalDatabase:
  host: your-db-host
  port: 5432
  user: keycloak
  password: your-password
  database: keycloak
```

### High Availability

For production deployments with multiple replicas:

```yaml
replicaCount: 3

cache:
  enabled: true
  stack: kubernetes
```

### Ingress with TLS

```yaml
ingress:
  enabled: true
  hostname: keycloak.example.com
  tls: true
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
```

## Security Considerations

- The chart runs as non-root user (UID 1001) by default
- `readOnlyRootFilesystem` is enabled for optimized images
- Network policies restrict traffic by default
- Secrets are mounted as files instead of environment variables

## Upgrading

### To 1.0.0

Initial release. No upgrade path required.

## Troubleshooting

### Pod fails to start with optimized image

Ensure you're not setting build-time environment variables like `KC_FEATURES` with optimized images. These images are pre-built.

### Database connection issues

Check that PostgreSQL is running and the credentials match:

```bash
kubectl get pods -l app.kubernetes.io/component=primary
kubectl logs <keycloak-pod> -c keycloak
```

## License

This chart is licensed under the Apache 2.0 License.

## Links

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [BySamio Images Repository](https://github.com/bysamio/images)
- [BySamio Charts Repository](https://github.com/bysamio/charts)
