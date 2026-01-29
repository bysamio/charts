# MariaDB Helm Chart

A Helm chart for deploying [MariaDB](https://mariadb.org/) on Kubernetes.

## Overview

This chart deploys MariaDB, a community-developed fork of MySQL, on Kubernetes using the official MariaDB Docker images.

## Features

- **Official Images**: Uses official MariaDB Docker images
- **Standalone & Replication**: Support for both standalone and primary-replica architectures
- **Custom Configuration**: Flexible configuration via ConfigMap
- **Persistence**: Persistent storage with PVC support
- **Security**: Comprehensive securityContext and network policy support
- **Metrics**: Optional Prometheus metrics exporter

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

### From OCI Registry

```bash
helm install mariadb oci://ghcr.io/bysamio/charts/mariadb \
  --namespace database \
  --create-namespace \
  --set auth.rootPassword=your-root-password \
  --set auth.database=mydb \
  --set auth.username=myuser \
  --set auth.password=your-user-password
```

### From Source

```bash
helm install mariadb ./mariadb \
  --namespace database \
  --create-namespace
```

## Configuration

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | MariaDB image repository | `mariadb` |
| `image.tag` | MariaDB image tag | `12.0.2` |
| `architecture` | MariaDB architecture (`standalone` or `replication`) | `standalone` |
| `auth.rootPassword` | MariaDB root password | `""` (auto-generated) |
| `auth.username` | Custom database username | `""` |
| `auth.password` | Custom database user password | `""` |
| `auth.database` | Custom database name | `my_database` |
| `primary.persistence.enabled` | Enable persistence | `true` |
| `primary.persistence.size` | PVC size | `8Gi` |

### Standalone Mode

```yaml
architecture: standalone

auth:
  rootPassword: "secure-root-password"
  username: "appuser"
  password: "secure-user-password"
  database: "appdb"

primary:
  persistence:
    enabled: true
    size: 10Gi
```

### Replication Mode

For high availability with secondary replicas:

```yaml
architecture: replication

auth:
  rootPassword: "secure-root-password"
  replicationUser: replicator
  replicationPassword: "secure-replication-password"

secondary:
  replicaCount: 2
  persistence:
    enabled: true
    size: 10Gi
```

### Using an Existing Secret

```yaml
auth:
  existingSecret: my-mariadb-secret
```

The secret should contain:
- `mariadb-root-password`
- `mariadb-password` (for custom user)
- `mariadb-replication-password` (if replication enabled)

### Custom MariaDB Configuration

```yaml
primary:
  configuration: |-
    [mysqld]
    skip-name-resolve
    explicit_defaults_for_timestamp
    basedir=/usr
    datadir=/var/lib/mysql
    port=3306
    socket=/run/mysqld/mysqld.sock
    max_allowed_packet=64M
    max_connections=200
    innodb_buffer_pool_size=256M
```

### Resource Limits

```yaml
primary:
  resources:
    requests:
      cpu: 250m
      memory: 256Mi
    limits:
      cpu: 1000m
      memory: 1Gi
```

## Security Considerations

- Configure strong passwords for root and application users
- Use `auth.existingSecret` for production deployments
- Enable network policies to restrict access
- Consider enabling TLS for client connections

## Upgrading

### To 1.0.0

Initial release. No upgrade path required.

## Troubleshooting

### Connection refused

Check that the pod is running:

```bash
kubectl get pods -l app.kubernetes.io/name=mariadb
kubectl logs <mariadb-pod>
```

### Authentication failures

Verify credentials:

```bash
kubectl get secret <release-name>-mariadb -o jsonpath='{.data.mariadb-root-password}' | base64 -d
```

### Slow queries

Enable slow query logging:

```yaml
primary:
  configuration: |-
    [mysqld]
    slow_query_log=1
    slow_query_log_file=/var/log/mysql/slow.log
    long_query_time=2
```

## License

This chart is licensed under the Apache 2.0 License.

## Links

- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [BySamio Charts Repository](https://github.com/bysamio/charts)
