# WordPress Helm Chart

A production-ready WordPress deployment using the official WordPress Docker image with auto-installation capabilities.

## Overview

This chart deploys WordPress with automatic initial setup, MariaDB database backend, and optional Memcached caching using official Docker images.

## Features

- **Auto-Installation**: Automatically completes WordPress initial setup when credentials are provided
- **Official Images**: Uses `wordpress:6.8.2-apache` official Docker image
- **Database Integration**: Includes MariaDB as a subchart dependency
- **Caching Support**: Optional Memcached integration for improved performance
- **Health Checks**: Comprehensive liveness and readiness probes
- **Security**: Proper security contexts and pod security standards
- **Scalability**: Configurable resource limits and horizontal scaling support

## Prerequisites

- Kubernetes 1.19+
- Helm 3.8+
- Persistent Volume provisioner support in the underlying infrastructure

## Installing the Chart

### Basic Installation

```bash
helm install my-wordpress oci://registry-1.docker.io/bysam/wordpress
```

### With Custom Values

```bash
helm install my-wordpress oci://registry-1.docker.io/bysam/wordpress \
  --set wordpressUsername=admin \
  --set wordpressPassword=secure-password \
  --set wordpressEmail=admin@example.com
```

### Using Values File

Create a `values.yaml` file:

```yaml
wordpressUsername: admin
wordpressPassword: secure-password123
wordpressEmail: admin@example.com
wordpressBlogName: "My WordPress Site"

service:
  type: LoadBalancer

persistence:
  enabled: true
  size: 10Gi

mariadb:
  auth:
    rootPassword: secure-root-password
    database: wordpress
    username: wpuser
    password: secure-db-password
```

Then install:

```bash
helm install my-wordpress oci://registry-1.docker.io/bysam/wordpress -f values.yaml
```

## Configuration

The following table lists the configurable parameters and their default values.

### WordPress Configuration

| Parameter              | Description                                       | Default            |
| ---------------------- | ------------------------------------------------- | ------------------ |
| `wordpressUsername`    | WordPress admin username                          | `user`             |
| `wordpressPassword`    | WordPress admin password                          | `""`               |
| `wordpressEmail`       | WordPress admin email                             | `user@example.com` |
| `wordpressBlogName`    | WordPress blog name                               | `User's Blog!`     |
| `wordpressTablePrefix` | WordPress database table prefix                   | `wp_`              |
| `wordpressScheme`      | WordPress URL scheme (http/https)                 | `http`             |
| `existingSecret`       | Name of existing secret for WordPress credentials | `""`               |

### Auto-Installation

| Parameter                      | Description                        | Default           |
| ------------------------------ | ---------------------------------- | ----------------- |
| `autoInstall.enabled`          | Enable WordPress auto-installation | `true`            |
| `autoInstall.image.repository` | Auto-install sidecar image         | `curlimages/curl` |
| `autoInstall.image.tag`        | Auto-install sidecar image tag     | `8.11.0`          |

### Service Configuration

| Parameter                 | Description        | Default        |
| ------------------------- | ------------------ | -------------- |
| `service.type`            | Service type       | `LoadBalancer` |
| `service.port`            | Service port       | `80`           |
| `service.httpsPort`       | HTTPS service port | `443`          |
| `service.nodePorts.http`  | NodePort for HTTP  | `""`           |
| `service.nodePorts.https` | NodePort for HTTPS | `""`           |

### Persistence Configuration

| Parameter                   | Description         | Default             |
| --------------------------- | ------------------- | ------------------- |
| `persistence.enabled`       | Enable persistence  | `true`              |
| `persistence.storageClass`  | Storage class       | `""`                |
| `persistence.accessModes`   | Access modes        | `["ReadWriteOnce"]` |
| `persistence.size`          | Storage size        | `10Gi`              |
| `persistence.existingClaim` | Use an existing PVC | `""`                |
| `persistence.dataSource`    | Data source for PVC | `{}`                |

### Resource Configuration

| Parameter                   | Description    | Default |
| --------------------------- | -------------- | ------- |
| `resources.limits.cpu`      | CPU limit      | `""`    |
| `resources.limits.memory`   | Memory limit   | `""`    |
| `resources.requests.cpu`    | CPU request    | `300m`  |
| `resources.requests.memory` | Memory request | `512Mi` |

### Security Configuration

| Parameter                               | Description                          | Default |
| --------------------------------------- | ------------------------------------ | ------- |
| `podSecurityContext.enabled`            | Enable pod security context          | `true`  |
| `podSecurityContext.fsGroup`            | Pod security context fsGroup         | `33`    |
| `containerSecurityContext.enabled`      | Enable container security context    | `true`  |
| `containerSecurityContext.runAsUser`    | Container security context runAsUser | `33`    |
| `containerSecurityContext.runAsNonRoot` | Run as non-root user                 | `true`  |

### MariaDB Configuration

| Parameter                   | Description             | Default             |
| --------------------------- | ----------------------- | ------------------- |
| `mariadb.enabled`           | Enable MariaDB subchart | `true`              |
| `mariadb.auth.rootPassword` | MariaDB root password   | `""`                |
| `mariadb.auth.database`     | MariaDB database name   | `bitnami_wordpress` |
| `mariadb.auth.username`     | MariaDB username        | `bn_wordpress`      |
| `mariadb.auth.password`     | MariaDB password        | `""`                |

### Memcached Configuration

| Parameter                | Description               | Default |
| ------------------------ | ------------------------- | ------- |
| `memcached.enabled`      | Enable Memcached subchart | `false` |
| `memcached.service.port` | Memcached service port    | `11211` |

## Auto-Installation Feature

The WordPress chart includes an innovative auto-installation feature that automatically completes the WordPress initial setup process:

### How It Works

1. **Detection**: A sidecar container monitors the WordPress installation
2. **Setup Detection**: Detects if WordPress is in fresh installation state
3. **Form Submission**: Automatically submits the initial setup form with provided credentials
4. **Completion**: Redirects to WordPress admin dashboard once setup is complete

### Auto-installation Configuration

Auto-installation is enabled by default when WordPress credentials are provided:

```yaml
wordpressUsername: admin
wordpressPassword: secure-password123
wordpressEmail: admin@example.com
wordpressBlogName: "My Blog"
```

### Monitoring

Monitor the auto-installation process:

```bash
kubectl logs deployment/my-wordpress-wordpress -c auto-install -f
```

## Accessing WordPress

### Via LoadBalancer

```bash
kubectl get svc my-wordpress-wordpress
export SERVICE_IP=$(kubectl get svc --namespace default my-wordpress-wordpress --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
echo "WordPress URL: http://$SERVICE_IP/"
```

### Via NodePort

```bash
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services my-wordpress-wordpress)
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo "WordPress URL: http://$NODE_IP:$NODE_PORT/"
```

### Via Port Forward

```bash
kubectl port-forward svc/my-wordpress-wordpress 8080:80
echo "WordPress URL: http://localhost:8080/"
```

## Uninstalling the Chart

```bash
helm uninstall my-wordpress
```

## Troubleshooting

### Common Issues

1. **Auto-installation not working**: Check auto-install container logs
2. **Database connection issues**: Verify MariaDB credentials and connectivity
3. **Persistence issues**: Check PVC status and storage class availability

### Getting Support

- Check logs: `kubectl logs deployment/my-wordpress-wordpress`
- Check events: `kubectl get events --sort-by=.metadata.creationTimestamp`
- Verify configuration: `helm get values my-wordpress`

## Chart Dependencies

This chart depends on the following subcharts:

- `mariadb` (version ~1.0.1) - Database backend
- `memcached` (version ~1.0.1) - Optional caching layer

## Contributing

Contributions are welcome! Please refer to the main repository for contribution guidelines.

## License

This chart is licensed under the GPL-2.0+ license, consistent with WordPress licensing.
