# MinIO Helm Chart

A Helm chart for deploying [MinIO](https://min.io/) object storage on Kubernetes.

## Overview

This chart deploys MinIO in **standalone** or **distributed** mode with security-hardened defaults: non-root execution, read-only root filesystem, dropped capabilities, and network policies enabled by default.

## Features

- **Standalone & Distributed**: single-server or multi-replica erasure-coded deployment
- **Non-root execution**: runs as UID 1000 with `readOnlyRootFilesystem: true`
- **Existing secrets**: reference pre-created secrets for credentials
- **Init buckets**: optional Job to create default buckets on first deploy
- **Network policies**: enabled by default
- **ArgoCD compatible**: `useHelmHooks` toggle for the init-buckets Job

## Installing the Chart

```bash
# Standalone
helm install minio oci://ghcr.io/bysamio/charts/minio \
  --set auth.rootPassword=changeme

# Distributed (4 nodes, erasure coding)
helm install minio oci://ghcr.io/bysamio/charts/minio \
  --set mode=distributed \
  --set replicaCount=4 \
  --set auth.rootPassword=changeme
```

### Using an existing secret

```bash
kubectl create secret generic minio-creds \
  --from-literal=root-user=admin \
  --from-literal=root-password=supersecret

helm install minio oci://ghcr.io/bysamio/charts/minio \
  --set auth.existingSecret=minio-creds
```

## Parameters

### Image

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `image.registry` | string | `quay.io` | Image registry |
| `image.repository` | string | `minio/minio` | Image repository |
| `image.tag` | string | `RELEASE.2025-09-07T16-13-09Z` | Image tag |
| `image.pullPolicy` | string | `IfNotPresent` | Pull policy |

### Authentication

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `auth.rootUser` | string | `minioadmin` | Root username |
| `auth.rootPassword` | string | `""` | Root password (auto-generated if empty) |
| `auth.existingSecret` | string | `""` | Existing secret name (keys: `root-user`, `root-password`) |

### Deployment

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `mode` | string | `standalone` | `standalone` or `distributed` |
| `replicaCount` | int | `1` | Replicas (1 for standalone, >= 4 for distributed) |
| `drivesPerNode` | int | `1` | PVCs per node (distributed only) |
| `zones` | int | `1` | Number of server pools (distributed only) |

### Service

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `service.type` | string | `ClusterIP` | Service type |
| `service.ports.api` | int | `9000` | S3 API port |
| `service.ports.console` | int | `9001` | Console UI port |

### Ingress

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ingress.enabled` | bool | `false` | Enable API ingress |
| `consoleIngress.enabled` | bool | `false` | Enable Console ingress |

### Persistence

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `persistence.enabled` | bool | `true` | Enable persistent storage |
| `persistence.storageClass` | string | `""` | Storage class |
| `persistence.size` | string | `10Gi` | PVC size |
| `persistence.existingClaim` | string | `""` | Existing PVC (standalone only) |

### Security

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `podSecurityContext.runAsUser` | int | `1000` | UID |
| `podSecurityContext.fsGroup` | int | `1000` | FS group |
| `containerSecurityContext.readOnlyRootFilesystem` | bool | `true` | Read-only root filesystem |
| `networkPolicy.enabled` | bool | `true` | Enable NetworkPolicy |
| `networkPolicy.allowExternal` | bool | `true` | Allow external ingress to API/console |

### Init Buckets

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `initBuckets.enabled` | bool | `false` | Create buckets on deploy |
| `initBuckets.buckets` | list | `[]` | Bucket names to create |
| `initBuckets.useHelmHooks` | bool | `true` | Use Helm hooks (disable for ArgoCD) |
| `initBuckets.cleanupAfterFinished.enabled` | bool | `false` | TTL cleanup for the Job |

### Other

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `console.enabled` | bool | `true` | Enable browser console |
| `pdb.create` | bool | `false` | Create PodDisruptionBudget |
| `pdb.maxUnavailable` | int | `1` | Max unavailable pods |
| `environment` | object | `{}` | Extra MinIO env vars as key-value map |
| `extraEnvVars` | list | `[]` | Extra env vars (valueFrom-compatible) |

## Standalone vs Distributed

| | Standalone | Distributed |
|--|-----------|-------------|
| Replicas | 1 | 4+ (must be even) |
| Erasure coding | No | Yes |
| Data protection | None (single copy) | Survives N/2-1 node failures |
| Pod management | OrderedReady | Parallel |
| Use case | Dev, staging | Production |

## ArgoCD Usage

Disable Helm hooks and use ArgoCD hook annotations:

```yaml
initBuckets:
  enabled: true
  useHelmHooks: false
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
  buckets:
    - my-bucket
```

## Upgrading

### To 1.0.0

Initial release. No upgrade path required.
