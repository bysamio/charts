# PostgreSQL Helm Chart

A Helm chart for deploying [PostgreSQL](https://www.postgresql.org/) using BySamio hardened Docker images.

## Overview

This chart deploys PostgreSQL, the world's most advanced open-source relational database, on Kubernetes. It uses BySamio's hardened container images that run as non-root (UID 1001) with security best practices.

## Features

- **Hardened Images**: Uses BySamio's security-hardened PostgreSQL images
- **Non-root Execution**: Runs as UID 1001 for enhanced security
- **Standalone & Replication**: Support for both standalone and primary-replica architectures
- **Metrics & Monitoring**: Prometheus exporter, ServiceMonitor, and PrometheusRule support
- **Security**: Network policies, PodDisruptionBudget, and comprehensive securityContext
- **Backup**: Built-in backup cronjob support
- **Password Files**: Mount credentials as files for enhanced security

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

### From OCI Registry

```bash
helm install postgresql oci://ghcr.io/bysamio/charts/postgresql \
  --namespace database \
  --create-namespace \
  --set auth.postgresPassword=your-admin-password \
  --set auth.password=your-user-password \
  --set auth.database=mydb \
  --set auth.username=myuser
```

### From Source

```bash
helm install postgresql ./postgresql \
  --namespace database \
  --create-namespace
```

## Configuration

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | PostgreSQL image repository | `ghcr.io/bysamio/postgresql` |
| `image.tag` | PostgreSQL image tag | `17.7-alpine` |
| `architecture` | PostgreSQL architecture (`standalone` or `replication`) | `standalone` |
| `auth.postgresPassword` | Password for the postgres admin user | `""` (auto-generated) |
| `auth.username` | Custom database username | `""` |
| `auth.password` | Custom database user password | `""` (auto-generated) |
| `auth.database` | Custom database name | `""` |
| `auth.usePasswordFiles` | Mount credentials as files | `true` |
| `primary.persistence.enabled` | Enable persistence | `true` |
| `primary.persistence.size` | PVC size | `8Gi` |

### Standalone Mode

Default deployment creates a single PostgreSQL instance:

```yaml
architecture: standalone

auth:
  postgresPassword: "secure-admin-password"
  username: "appuser"
  password: "secure-user-password"
  database: "appdb"

primary:
  persistence:
    enabled: true
    size: 10Gi
```

### Replication Mode

For high availability with read replicas:

```yaml
architecture: replication

auth:
  postgresPassword: "secure-admin-password"
  replicationPassword: "secure-replication-password"

readReplicas:
  replicaCount: 2
  persistence:
    enabled: true
    size: 10Gi
```

### Using an Existing Secret

```yaml
auth:
  existingSecret: my-postgresql-secret
  secretKeys:
    adminPasswordKey: postgres-password
    userPasswordKey: password
    replicationPasswordKey: replication-password
```

### Metrics and Monitoring

Enable Prometheus metrics exporter:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    namespace: monitoring
```

### Custom PostgreSQL Configuration

```yaml
primary:
  configuration: |-
    max_connections = 200
    shared_buffers = 256MB
    effective_cache_size = 768MB
    maintenance_work_mem = 128MB
    checkpoint_completion_target = 0.9
    wal_buffers = 8MB
    default_statistics_target = 100
    random_page_cost = 1.1
    effective_io_concurrency = 200

  pgHbaConfiguration: |-
    local all all trust
    host all all 127.0.0.1/32 md5
    host all all ::1/128 md5
    host all all 0.0.0.0/0 md5
```

### Backup Configuration

Enable automatic backups:

```yaml
backup:
  enabled: true
  cronjob:
    schedule: "@daily"
    storage:
      enabled: true
      size: 20Gi
```

## Security Considerations

- Runs as non-root user (UID 1001) by default
- `readOnlyRootFilesystem` is enabled
- Network policies restrict traffic by default
- Passwords mounted as files (not environment variables) when `auth.usePasswordFiles: true`
- PodDisruptionBudget ensures availability during updates

## Upgrading

### To 1.0.0

Initial release. No upgrade path required.

## Troubleshooting

### Connection refused

Check that the pod is running and ready:

```bash
kubectl get pods -l app.kubernetes.io/name=postgresql
kubectl logs <postgresql-pod>
```

### Permission denied on data directory

Ensure the PVC has correct permissions. You may need to enable volume permissions init container:

```yaml
volumePermissions:
  enabled: true
```

### Replication lag

Monitor replication status:

```sql
SELECT * FROM pg_stat_replication;
```

## License

This chart is licensed under the Apache 2.0 License.

## Links

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [BySamio Images Repository](https://github.com/bysamio/images)
- [BySamio Charts Repository](https://github.com/bysamio/charts)
