# Gotenberg Helm Chart

Minimal Helm chart for deploying Gotenberg as an internal Kubernetes document conversion service.

## Quick Start

```bash
helm upgrade --install gotenberg ./gotenberg \
  --namespace gotenberg \
  --create-namespace
```

## Defaults

This chart deploys one `gotenberg/gotenberg:8-chromium` replica behind a `ClusterIP` service on port `3000`.

The defaults disable the debug route, disable `downloadFrom`, disable webhooks, clear Chromium cache and cookies between conversions, and run the container as UID `1001` without privilege escalation.

## Parameters

| Parameter | Description | Default |
|---|---|---|
| `replicaCount` | Number of Gotenberg pods | `1` |
| `image.repository` | Gotenberg image repository | `gotenberg/gotenberg` |
| `image.tag` | Gotenberg image tag | `8-chromium` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override full release name | `""` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `3000` |
| `service.annotations` | Service annotations | `{}` |
| `resources.requests.cpu` | CPU request | `250m` |
| `resources.requests.memory` | Memory request | `512Mi` |
| `resources.limits.cpu` | CPU limit | `1` |
| `resources.limits.memory` | Memory limit | `1Gi` |
| `securityContext.runAsUser` | Container user ID | `1001` |
| `securityContext.allowPrivilegeEscalation` | Allow privilege escalation | `false` |
| `securityContext.privileged` | Run privileged container | `false` |
| `securityContext.readOnlyRootFilesystem` | Mount root filesystem read-only | `false` |
| `env.API_TIMEOUT` | Request timeout | `60s` |
| `env.API_BODY_LIMIT` | Multipart body limit | `50MB` |
| `env.API_DISABLE_DOWNLOAD_FROM` | Disable `downloadFrom` URL fetching | `true` |
| `env.API_ENABLE_DEBUG_ROUTE` | Enable debug route | `false` |
| `env.CHROMIUM_MAX_CONCURRENCY` | Chromium conversion concurrency | `2` |
| `env.CHROMIUM_MAX_QUEUE_SIZE` | Chromium queue size | `20` |
| `env.CHROMIUM_CLEAR_CACHE` | Clear Chromium cache after each conversion | `true` |
| `env.CHROMIUM_CLEAR_COOKIES` | Clear Chromium cookies after each conversion | `true` |
| `env.WEBHOOK_DISABLE` | Disable webhook callbacks | `true` |
| `podAnnotations` | Pod annotations | `{}` |
| `podLabels` | Pod labels | `{}` |
| `podSecurityContext` | Pod security context | `{}` |
| `automountServiceAccountToken` | Mount service account token in pods | `false` |
| `livenessProbe` | Container liveness probe | `/health` on `http` |
| `readinessProbe` | Container readiness probe | `/health` on `http` |
| `startupProbe` | Container startup probe | `/health` on `http` |
| `networkPolicy.enabled` | Create a NetworkPolicy | `true` |
| `networkPolicy.allowExternal` | Allow ingress to the HTTP port from any pod | `true` |
| `networkPolicy.allowExternalEgress` | Allow all egress from Gotenberg pods | `true` |
| `networkPolicy.extraIngress` | Additional NetworkPolicy ingress rules | `[]` |
| `networkPolicy.extraEgress` | Additional NetworkPolicy egress rules | `[]` |
| `nodeSelector` | Node selector for pods | `{}` |
| `tolerations` | Pod tolerations | `[]` |
| `affinity` | Pod affinity rules | `{}` |
| `topologySpreadConstraints` | Pod topology spread constraints | `[]` |

## Network Policy

`networkPolicy.enabled` defaults to `true`. Set `networkPolicy.allowExternal` to `false` to require client pods to carry the rendered fullname client label. For a release named `gotenberg`, that label is:

```yaml
gotenberg-client: "true"
```

Set `networkPolicy.allowExternalEgress` to `false` and provide `networkPolicy.extraEgress` when you want to restrict outbound traffic.

## References

- [Gotenberg documentation](https://gotenberg.dev/docs/configuration)
- [Community Gotenberg chart](https://artifacthub.io/packages/helm/maikumori/gotenberg)
