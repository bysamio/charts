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

The following tables document all available configuration options in `values.yaml`.

---

### Global Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `global.imageRegistry` | string | `""` | Global Docker Image registry |
| `global.imagePullSecrets` | array | `[]` | Global Docker registry secret names as an array |
| `global.defaultStorageClass` | string | `""` | Global default StorageClass for Persistent Volume(s) |

---

### Common Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `nameOverride` | string | `""` | String to partially override common.names.fullname |
| `fullnameOverride` | string | `""` | String to fully override common.names.fullname |
| `namespaceOverride` | string | `""` | String to fully override common.names.namespace |
| `commonLabels` | object | `{}` | Add labels to all deployed resources |
| `commonAnnotations` | object | `{}` | Add annotations to all deployed resources |
| `clusterDomain` | string | `"cluster.local"` | Kubernetes cluster domain |
| `extraDeploy` | array | `[]` | Array of extra objects to deploy with the release |

---

### Image Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `image.registry` | string | `"docker.io"` | Memcached image registry |
| `image.repository` | string | `"memcached"` | Memcached image repository |
| `image.tag` | string | `"1.6.24-alpine"` | Memcached image tag (immutable tags recommended) |
| `image.digest` | string | `""` | Memcached image digest (overrides tag if set) |
| `image.pullPolicy` | string | `"IfNotPresent"` | Memcached image pull policy |
| `image.pullSecrets` | array | `[]` | Memcached image pull secrets |
| `image.debug` | boolean | `false` | Enable debug mode |

---

### Authentication Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `auth.enabled` | boolean | `false` | Enable SASL authentication |
| `auth.username` | string | `""` | SASL username |
| `auth.password` | string | `""` | SASL password |
| `auth.existingPasswordSecret` | string | `""` | Existing secret with Memcached credentials (must contain `memcached-password` key) |

---

### Memcached Configuration Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `architecture` | string | `"standalone"` | Memcached architecture (`standalone` or `high-availability`) |
| `replicaCount` | number | `1` | Number of Memcached replicas to deploy |
| `command` | array | `[]` | Override default container command |
| `args` | array | `[]` | Override default container args |
| `extraEnvVars` | array | `[]` | Extra environment variables |
| `extraEnvVarsCM` | string | `""` | ConfigMap with extra env vars |
| `extraEnvVarsSecret` | string | `""` | Secret with extra env vars |
| `containerPorts.memcached` | number | `11211` | Memcached container port |
| `extraContainerPorts` | array | `[]` | Extra list of additional ports for container |

---

### Deployment Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `updateStrategy.type` | string | `"RollingUpdate"` | Statefulset strategy type |
| `schedulerName` | string | `""` | Use alternate scheduler (e.g., stork) |
| `terminationGracePeriodSeconds` | string | `""` | Seconds pod needs to terminate gracefully |
| `topologySpreadConstraints` | array | `[]` | Topology spread constraints for pod assignment |
| `priorityClassName` | string | `""` | Priority Class to use for pods |
| `automountServiceAccountToken` | boolean | `false` | Mount Service Account token in pods |
| `hostAliases` | array | `[]` | Pod host aliases |
| `extraVolumes` | array | `[]` | Extra list of additional volumes |
| `extraVolumeMounts` | array | `[]` | Extra list of additional volumeMounts |
| `sidecars` | array | `[]` | Add additional sidecar containers |
| `initContainers` | array | `[]` | Add additional init containers |
| `podLabels` | object | `{}` | Extra labels for pods |
| `podAnnotations` | object | `{}` | Annotations for pods |

---

### Pod Scheduling Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `podAffinityPreset` | string | `""` | Pod affinity preset (soft or hard) |
| `podAntiAffinityPreset` | string | `""` | Pod anti-affinity preset (soft or hard) |
| `nodeAffinityPreset.type` | string | `""` | Node affinity preset type (soft or hard) |
| `nodeAffinityPreset.key` | string | `""` | Node label key to match |
| `nodeAffinityPreset.values` | array | `[]` | Node label values to match |
| `affinity` | object | `{}` | Affinity for pod assignment |
| `nodeSelector` | object | `{}` | Node labels for pod assignment |
| `tolerations` | array | `[]` | Tolerations for pod assignment |

---

### Resource Management Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `resourcesPreset` | string | `"nano"` | Resource preset (none, nano, micro, small, medium, large, xlarge, 2xlarge) |
| `resources` | object | `{}` | Container resource requests and limits (overrides resourcesPreset) |

---

### Security Context Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `podSecurityContext.enabled` | boolean | `true` | Enable pods' Security Context |
| `podSecurityContext.fsGroupChangePolicy` | string | `"Always"` | Filesystem group change policy |
| `podSecurityContext.sysctls` | array | `[]` | Set kernel settings using sysctl interface |
| `podSecurityContext.supplementalGroups` | array | `[]` | Set filesystem extra groups |
| `podSecurityContext.fsGroup` | number | `11211` | Pod Security Context fsGroup |
| `containerSecurityContext.enabled` | boolean | `true` | Enable containers' Security Context |
| `containerSecurityContext.seLinuxOptions` | object | `{}` | SELinux options in container |
| `containerSecurityContext.runAsUser` | number | `11211` | Containers' Security Context runAsUser |
| `containerSecurityContext.runAsGroup` | number | `11211` | Containers' Security Context runAsGroup |
| `containerSecurityContext.runAsNonRoot` | boolean | `true` | Run containers as non-root |
| `containerSecurityContext.privileged` | boolean | `false` | Set container privileged |
| `containerSecurityContext.readOnlyRootFilesystem` | boolean | `false` | Set read-only root filesystem |
| `containerSecurityContext.allowPrivilegeEscalation` | boolean | `false` | Allow privilege escalation |
| `containerSecurityContext.capabilities.drop` | array | `["ALL"]` | List of capabilities to drop |
| `containerSecurityContext.seccompProfile.type` | string | `"RuntimeDefault"` | Seccomp profile type |

---

### Health Check Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `livenessProbe.enabled` | boolean | `true` | Enable livenessProbe |
| `livenessProbe.tcpSocket.port` | string | `"memcached"` | Port for TCP socket probe |
| `livenessProbe.initialDelaySeconds` | number | `30` | Initial delay for livenessProbe |
| `livenessProbe.periodSeconds` | number | `10` | Period seconds for livenessProbe |
| `livenessProbe.timeoutSeconds` | number | `5` | Timeout seconds for livenessProbe |
| `livenessProbe.failureThreshold` | number | `6` | Failure threshold for livenessProbe |
| `livenessProbe.successThreshold` | number | `1` | Success threshold for livenessProbe |
| `readinessProbe.enabled` | boolean | `true` | Enable readinessProbe |
| `readinessProbe.tcpSocket.port` | string | `"memcached"` | Port for TCP socket probe |
| `readinessProbe.initialDelaySeconds` | number | `5` | Initial delay for readinessProbe |
| `readinessProbe.periodSeconds` | number | `5` | Period seconds for readinessProbe |
| `readinessProbe.timeoutSeconds` | number | `3` | Timeout seconds for readinessProbe |
| `readinessProbe.failureThreshold` | number | `6` | Failure threshold for readinessProbe |
| `readinessProbe.successThreshold` | number | `1` | Success threshold for readinessProbe |
| `startupProbe.enabled` | boolean | `false` | Enable startupProbe |
| `startupProbe.tcpSocket.port` | string | `"memcached"` | Port for TCP socket probe |
| `startupProbe.initialDelaySeconds` | number | `30` | Initial delay for startupProbe |
| `startupProbe.periodSeconds` | number | `10` | Period seconds for startupProbe |
| `startupProbe.timeoutSeconds` | number | `5` | Timeout seconds for startupProbe |
| `startupProbe.failureThreshold` | number | `6` | Failure threshold for startupProbe |
| `startupProbe.successThreshold` | number | `1` | Success threshold for startupProbe |
| `customLivenessProbe` | object | `{}` | Custom livenessProbe |
| `customReadinessProbe` | object | `{}` | Custom readinessProbe |
| `customStartupProbe` | object | `{}` | Custom startupProbe |
| `lifecycleHooks` | object | `{}` | LifecycleHooks for additional configuration |

---

### Service Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `service.type` | string | `"ClusterIP"` | Kubernetes Service type |
| `service.ports.memcached` | number | `11211` | Memcached service port |
| `service.nodePorts.memcached` | string | `""` | Node port for Memcached |
| `service.sessionAffinity` | string | `"None"` | Session Affinity (None or ClientIP) |
| `service.sessionAffinityConfig` | object | `{}` | Additional settings for sessionAffinity |
| `service.clusterIP` | string | `""` | Static clusterIP or None for headless services |
| `service.loadBalancerIP` | string | `""` | Load balancer IP |
| `service.loadBalancerSourceRanges` | array | `[]` | Allowed addresses when service is LoadBalancer |
| `service.externalTrafficPolicy` | string | `"Cluster"` | Enable client source IP preservation |
| `service.annotations` | object | `{}` | Annotations for service |
| `service.extraPorts` | array | `[]` | Extra ports to expose in service |

---

### Service Account Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `serviceAccount.create` | boolean | `true` | Enable creation of ServiceAccount |
| `serviceAccount.name` | string | `""` | Name of ServiceAccount to use |
| `serviceAccount.automountServiceAccountToken` | boolean | `false` | Auto mount ServiceAccountToken |
| `serviceAccount.annotations` | object | `{}` | Additional annotations for ServiceAccount |

---

### Pod Disruption Budget Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pdb.create` | boolean | `false` | Enable Pod Disruption Budget creation |
| `pdb.minAvailable` | string | `""` | Minimum number/percentage of pods to remain scheduled |
| `pdb.maxUnavailable` | string | `""` | Maximum number/percentage of pods that may be unavailable |

---

### Autoscaling Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `autoscaling.enabled` | boolean | `false` | Enable Horizontal Pod Autoscaler |
| `autoscaling.minReplicas` | number | `1` | Minimum number of replicas |
| `autoscaling.maxReplicas` | number | `11` | Maximum number of replicas |
| `autoscaling.targetCPU` | number | `50` | Target CPU utilization percentage |
| `autoscaling.targetMemory` | number | `50` | Target Memory utilization percentage |

---

### Metrics Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `metrics.enabled` | boolean | `false` | Enable Prometheus metrics exporter |
| `metrics.image.registry` | string | `"docker.io"` | Metrics exporter image registry |
| `metrics.image.repository` | string | `"prom/memcached-exporter"` | Metrics exporter image repository |
| `metrics.image.tag` | string | `"v0.14.0"` | Metrics exporter image tag |
| `metrics.image.digest` | string | `""` | Metrics exporter image digest |
| `metrics.image.pullPolicy` | string | `"IfNotPresent"` | Image pull policy |
| `metrics.image.pullSecrets` | array | `[]` | Image pull secrets |
| `metrics.containerPorts.metrics` | number | `9150` | Metrics container port |
| `metrics.livenessProbe.enabled` | boolean | `true` | Enable livenessProbe |
| `metrics.livenessProbe.initialDelaySeconds` | number | `15` | Initial delay |
| `metrics.livenessProbe.periodSeconds` | number | `10` | Period seconds |
| `metrics.livenessProbe.timeoutSeconds` | number | `5` | Timeout seconds |
| `metrics.livenessProbe.failureThreshold` | number | `3` | Failure threshold |
| `metrics.livenessProbe.successThreshold` | number | `1` | Success threshold |
| `metrics.readinessProbe.enabled` | boolean | `true` | Enable readinessProbe |
| `metrics.readinessProbe.initialDelaySeconds` | number | `5` | Initial delay |
| `metrics.readinessProbe.periodSeconds` | number | `10` | Period seconds |
| `metrics.readinessProbe.timeoutSeconds` | number | `3` | Timeout seconds |
| `metrics.readinessProbe.failureThreshold` | number | `3` | Failure threshold |
| `metrics.readinessProbe.successThreshold` | number | `1` | Success threshold |
| `metrics.startupProbe.enabled` | boolean | `false` | Enable startupProbe |
| `metrics.startupProbe.initialDelaySeconds` | number | `10` | Initial delay |
| `metrics.startupProbe.periodSeconds` | number | `10` | Period seconds |
| `metrics.startupProbe.timeoutSeconds` | number | `1` | Timeout seconds |
| `metrics.startupProbe.failureThreshold` | number | `15` | Failure threshold |
| `metrics.startupProbe.successThreshold` | number | `1` | Success threshold |
| `metrics.customLivenessProbe` | object | `{}` | Custom livenessProbe |
| `metrics.customReadinessProbe` | object | `{}` | Custom readinessProbe |
| `metrics.customStartupProbe` | object | `{}` | Custom startupProbe |
| `metrics.resourcesPreset` | string | `"nano"` | Resource preset |
| `metrics.resources` | object | `{}` | Resource requests and limits |
| `metrics.containerSecurityContext.enabled` | boolean | `true` | Enable container Security Context |
| `metrics.containerSecurityContext.seLinuxOptions` | object | `{}` | SELinux options |
| `metrics.containerSecurityContext.runAsUser` | number | `1001` | Run as user |
| `metrics.containerSecurityContext.runAsGroup` | number | `1001` | Run as group |
| `metrics.containerSecurityContext.runAsNonRoot` | boolean | `true` | Run as non-root |
| `metrics.containerSecurityContext.privileged` | boolean | `false` | Set privileged |
| `metrics.containerSecurityContext.readOnlyRootFilesystem` | boolean | `true` | Read-only root filesystem |
| `metrics.containerSecurityContext.allowPrivilegeEscalation` | boolean | `false` | Allow privilege escalation |
| `metrics.containerSecurityContext.capabilities.drop` | array | `["ALL"]` | Capabilities to drop |
| `metrics.containerSecurityContext.seccompProfile.type` | string | `"RuntimeDefault"` | Seccomp profile type |
| `metrics.service.ports.metrics` | number | `9150` | Metrics service port |
| `metrics.service.annotations` | object | `{prometheus.io/scrape: "true"}` | Annotations for metrics endpoint |
| `metrics.serviceMonitor.enabled` | boolean | `false` | Create ServiceMonitor for Prometheus Operator |
| `metrics.serviceMonitor.namespace` | string | `""` | Namespace for ServiceMonitor |
| `metrics.serviceMonitor.interval` | string | `""` | Interval for metrics scraping |
| `metrics.serviceMonitor.scrapeTimeout` | string | `""` | Timeout after which scrape is ended |
| `metrics.serviceMonitor.labels` | object | `{}` | Additional labels for ServiceMonitor |
| `metrics.serviceMonitor.selector` | object | `{}` | Prometheus instance selector labels |
| `metrics.serviceMonitor.relabelings` | array | `[]` | RelabelConfigs before scraping |
| `metrics.serviceMonitor.metricRelabelings` | array | `[]` | MetricRelabelConfigs before ingestion |
| `metrics.serviceMonitor.honorLabels` | boolean | `false` | Specify honorLabels parameter |
| `metrics.serviceMonitor.jobLabel` | string | `""` | Job name label in prometheus |

---

### Network Policy Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `networkPolicy.enabled` | boolean | `true` | Enable NetworkPolicy creation |
| `networkPolicy.allowExternal` | boolean | `true` | Don't require server label for connections |
| `networkPolicy.allowExternalEgress` | boolean | `true` | Allow pod to access any range of port |
| `networkPolicy.extraIngress` | array | `[]` | Add extra ingress rules to NetworkPolicy |
| `networkPolicy.extraEgress` | array | `[]` | Add extra egress rules to NetworkPolicy |
| `networkPolicy.ingressNSMatchLabels` | object | `{}` | Labels to match for traffic from other namespaces |
| `networkPolicy.ingressNSPodMatchLabels` | object | `{}` | Pod labels to match for traffic from other namespaces |

---

## Example Configurations

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
