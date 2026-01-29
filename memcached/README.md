# Memcached Helm Chart

A Helm chart for deploying [Memcached](https://memcached.org/) on Kubernetes.

## Overview

This chart deploys Memcached, a high-performance distributed memory object caching system, on Kubernetes using official Memcached Docker images.

## Features

- **Official Images**: Uses official Memcached Alpine images
- **Lightweight**: Minimal resource footprint
- **Scalable**: Easy horizontal scaling with multiple replicas
- **Security**: Comprehensive securityContext and network policy support
- **High Availability**: Support for multi-replica deployments

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8+

## Installing the Chart

### From OCI Registry

```bash
helm install memcached oci://ghcr.io/bysamio/charts/memcached \
  --namespace cache \
  --create-namespace
```

### From Source

```bash
helm install memcached ./memcached \
  --namespace cache \
  --create-namespace
```

## Configuration

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Memcached image repository | `memcached` |
| `image.tag` | Memcached image tag | `1.6.24-alpine` |
| `architecture` | Architecture (`standalone` or `high-availability`) | `standalone` |
| `replicaCount` | Number of Memcached replicas | `1` |
| `auth.enabled` | Enable SASL authentication | `false` |
| `auth.username` | SASL username | `""` |
| `auth.password` | SASL password | `""` |
| `containerPorts.memcached` | Memcached container port | `11211` |

### Basic Deployment

```yaml
replicaCount: 1

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi
```

### High Availability

For production deployments with multiple replicas:

```yaml
architecture: high-availability
replicaCount: 3

podAntiAffinityPreset: soft
```

### Authentication

Enable SASL authentication:

```yaml
auth:
  enabled: true
  username: memcached-user
  password: secure-password
```

Or use an existing secret:

```yaml
auth:
  enabled: true
  existingPasswordSecret: my-memcached-secret
```

### Memory Configuration

Configure memory limits via arguments:

```yaml
args:
  - -m 256  # Max memory in MB
  - -c 1024 # Max connections
  - -I 2m   # Max item size
```

### Resource Limits

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### Network Policy

Restrict access to specific namespaces:

```yaml
networkPolicy:
  enabled: true
  allowExternal: false
  ingressNSMatchLabels:
    app: my-app
```

## Usage

### Connecting from Applications

Connect to Memcached using the service DNS:

```
<release-name>-memcached.<namespace>.svc.cluster.local:11211
```

### Example with Python

```python
import memcache

mc = memcache.Client(['memcached.cache.svc.cluster.local:11211'])
mc.set('key', 'value')
value = mc.get('key')
```

### Example with PHP

```php
$memcached = new Memcached();
$memcached->addServer('memcached.cache.svc.cluster.local', 11211);
$memcached->set('key', 'value');
$value = $memcached->get('key');
```

## Security Considerations

- Enable SASL authentication for production
- Use network policies to restrict access
- Run with minimal privileges (non-root where possible)
- Monitor memory usage to prevent evictions

## Upgrading

### To 1.0.0

Initial release. No upgrade path required.

## Troubleshooting

### Connection refused

Check that the pod is running:

```bash
kubectl get pods -l app.kubernetes.io/name=memcached
kubectl logs <memcached-pod>
```

### High eviction rate

Increase memory allocation:

```yaml
args:
  - -m 512  # Increase max memory
```

### Check stats

Use telnet or nc to check Memcached stats:

```bash
kubectl exec -it <memcached-pod> -- sh -c "echo stats | nc localhost 11211"
```

## License

This chart is licensed under the Apache 2.0 License.

## Links

- [Memcached Documentation](https://memcached.org/)
- [Memcached Wiki](https://github.com/memcached/memcached/wiki)
- [BySamio Charts Repository](https://github.com/bysamio/charts)
