# CasePack SPA Helm Chart

Deploys the CasePack React SPA (Nginx-served static files) to Kubernetes.

## Installing

```bash
helm install casepack-spa oci://ghcr.io/bysamio/charts/casepack-spa \
  --namespace casepack --create-namespace \
  -f values-prod.yaml
```

## Configuration

| Parameter | Description | Default |
|---|---|---|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Docker image repository | `ghcr.io/bysamio/casepack-spa` |
| `image.tag` | Image tag (defaults to appVersion) | `""` |
| `config.apiBaseUrl` | API base URL injected at runtime | `/api` |
| `config.oidcAuthority` | OIDC issuer URL | `""` |
| `config.oidcClientId` | OIDC client ID | `casepack-spa` |
| `ingress.enabled` | Enable Ingress | `false` |
| `ingress.className` | Ingress class | `nginx` |
| `ingress.hosts` | Ingress host rules | `[]` |
| `ingress.tls` | TLS configuration | `[]` |
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `3` |
| `resources.requests.cpu` | CPU request | `50m` |
| `resources.requests.memory` | Memory request | `32Mi` |
| `resources.limits.cpu` | CPU limit | `200m` |
| `resources.limits.memory` | Memory limit | `64Mi` |

## Runtime Configuration

The Docker entrypoint generates `/usr/share/nginx/html/config.js` from
environment variables at container startup. This allows the same image
to be deployed across environments without rebuilding.

The SPA reads `window.__RUNTIME_CONFIG__` for:
- `API_BASE_URL` — backend API endpoint
- `OIDC_AUTHORITY` — Keycloak realm URL
- `OIDC_CLIENT_ID` — OIDC client identifier
