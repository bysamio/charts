# CasePack API Helm Chart

Deploy CasePack API on Kubernetes — multi-tenant incident evidence management for MSPs. Self-host-first. Built for NIS2-style compliance workflows.

## Prerequisites

- Kubernetes 1.26+
- Helm 3.10+
- PostgreSQL 17 instance with a `casepack` database and user
- Keycloak with a `casepack` realm configured (OIDC)
- S3-compatible object storage (SeaweedFS, Ceph RGW, AWS S3, etc.)

## Install

```bash
helm install casepack-api oci://ghcr.io/bysamio/charts/casepack-api \
  --version 0.3.0 \
  --namespace casepack \
  --create-namespace \
  -f my-values.yaml
```

## Upgrade

```bash
helm upgrade casepack-api oci://ghcr.io/bysamio/charts/casepack-api \
  --version 0.4.0 \
  -f my-values.yaml
```

## Uninstall

```bash
helm uninstall casepack-api --namespace casepack
```

## Quick Start Values

Create a `my-values.yaml` file:

```yaml
image:
  repository: ghcr.io/bysamio/casepack-api

config:
  oidcIssuerUri: "https://auth.example.com/realms/casepack"
  s3Endpoint: "http://seaweedfs-s3.casepack.svc.cluster.local:8333"
  s3PublicEndpoint: "https://s3.casepack.example.com"
  corsOrigins: "https://casepack.example.com"

secrets:
  existingSecret: "casepack-api-secrets"

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: api.casepack.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: casepack-api-tls
      hosts:
        - api.casepack.example.com
```

## Secrets

The chart expects a Kubernetes Secret with the following keys:

| Key | Description |
|---|---|
| `DB_URL` | PostgreSQL JDBC URL (e.g. `jdbc:postgresql://postgres:5432/casepack`) |
| `DB_USER` | Database username |
| `DB_PASS` | Database password |
| `S3_ACCESS_KEY` | S3 access key |
| `S3_SECRET_KEY` | S3 secret key |
| `S3_PUBLIC_ENDPOINT` | *(optional)* Browser-facing endpoint for presigned upload/download URLs. Prefer `config.s3PublicEndpoint` when using chart values. |
| `CASEPACK_LICENSE_TOKEN` | **Required.** License JWT from [bysam.io](https://bysam.io) |
| `CASEPACK_LICENSE_TOKEN_FILE` | *(optional)* Path to license file (alternative to inline token) |
| `CASEPACK_LICENSE_PUBLIC_KEY` | *(optional)* Base64-encoded Ed25519 JWK fallback for license verification. Omit when `CASEPACK_LICENSE_KEY_SOURCE=jwks`. |
| `CASEPACK_PROVISIONING_SECRET` | *(optional)* HMAC-SHA256 shared secret for provisioning webhook verification (64-char hex string) |
| `CASEPACK_TEST_DATA_RESET_HMAC_SECRET` | *(optional)* HMAC-SHA256 shared secret for stage/dev-only test-data reset |
| `CASEPACK_KEYCLOAK_SA_CLIENT_ID` | *(optional)* Keycloak service account client ID for Admin API user management |
| `CASEPACK_KEYCLOAK_SA_CLIENT_SECRET` | *(optional)* Keycloak service account client secret |
| `CASEPACK_KEYCLOAK_SPA_CLIENT_ID` | OIDC client ID for action-email redirect (default: `casepack-spa`) |
| `CASEPACK_KEYCLOAK_SPA_REDIRECT_URI` | *(optional)* Redirect URI after Keycloak action completion |
| `CASEPACK_KEYCLOAK_ACTION_TOKEN_LIFESPAN` | Action-link validity in seconds (default: `259200` / 72 hours) |
| `CASEPACK_PROVISIONING_INBOX_ENABLED` | `false` | Persist valid provisioning events and process them asynchronously with deduplication/retry |

Create the secret:

```bash
kubectl create secret generic casepack-api-secrets \
  --namespace casepack \
  --from-literal=DB_URL="jdbc:postgresql://postgres:5432/casepack" \
  --from-literal=DB_USER=casepack \
  --from-literal=DB_PASS=changeme \
  --from-literal=S3_ACCESS_KEY=admin \
  --from-literal=S3_SECRET_KEY=changeme
```

Then reference it:

```yaml
secrets:
  existingSecret: "casepack-api-secrets"
```

## Parameters

### Application Configuration

| Parameter | Description | Default |
|---|---|---|
| `config.serverPort` | API server port | `8080` |
| `config.forwardHeadersStrategy` | Reverse proxy header strategy | `NATIVE` |
| `config.oidcIssuerUri` | Keycloak realm issuer URI | `http://keycloak:8082/realms/casepack` |
| `config.oidcJwkSetUri` | JWK set URI (auto-derived from issuer if empty) | `""` |
| `config.s3Endpoint` | Internal S3 endpoint URL used by API server-side storage operations | `http://seaweedfs-s3:8333` |
| `config.s3PublicEndpoint` | Optional browser-facing S3 endpoint used for presigned URLs; blank falls back to `config.s3Endpoint` | `""` |
| `config.s3Region` | S3 region | `us-east-1` |
| `config.s3Bucket` | Default S3 bucket name | `casepack` |
| `config.s3PathStyle` | Use path-style S3 access (required for SeaweedFS / Ceph RGW) | `true` |
| `config.s3PresignExpiry` | Presigned URL expiry in seconds | `900` |
| `config.s3AutoCreateBucket` | Auto-create S3 bucket on startup | `true` |
| `config.s3BucketPerTenant` | Enable per-tenant S3 bucket isolation | `false` |
| `config.evidenceMaxBytes` | Max evidence file size in bytes | `104857600` (100 MB) |
| `config.evidenceAllowedTypes` | Allowed content types (empty = all) | `""` |
| `config.rateLimitEnabled` | Enable per-tenant rate limiting | `true` |
| `config.rateLimitInit` | Evidence init requests per minute | `30` |
| `config.rateLimitFinalize` | Evidence finalize requests per minute | `30` |
| `config.rateLimitGlobal` | Global requests per minute | `300` |
| `config.rateLimitWebhookIntake` | Webhook intake requests per minute | `60` |
| `config.exportMaxItems` | Max evidence items per export | `100` |
| `config.exportMaxBytes` | Max export size in bytes | `536870912` (512 MB) |
| `config.exportPoolSize` | Async export thread pool size | `2` |
| `config.webhookEnabled` | Enable webhook intake endpoints | `true` |
| `config.webhookMaxPayload` | Max webhook payload size in bytes | `1048576` (1 MB) |
| `config.timelineEnabled` | Enable NIS2 timeline/milestone endpoints | `true` |
| `config.corsOrigins` | Comma-separated allowed CORS origins | `http://localhost:5173` |
| `config.swaggerPublic` | Allow unauthenticated Swagger UI access | `false` |
| `config.javaOpts` | JVM options | `-Xms256m -Xmx512m` |
| `config.provisioningInboxEnabled` | Provisioning events durable async processing flag | `false` |
| `config.testDataResetEnabled` | Enable stage/dev/test-only internal test-data reset endpoint | `false` |
| `config.testDataResetEnvironment` | Reset environment guard; use `staging`, `dev`, or `test` outside production | `local` |

### Image

| Parameter | Description | Default |
|---|---|---|
| `image.repository` | Container image repository | `ghcr.io/bysamio/casepack-api` |
| `image.tag` | Image tag (defaults to `appVersion`) | `""` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |

### Ingress

| Parameter | Description | Default |
|---|---|---|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `nginx` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts configuration | see [values.yaml](values.yaml) |
| `ingress.tls` | TLS configuration | `[]` |

### Resources & Scaling

| Parameter | Description | Default |
|---|---|---|
| `replicaCount` | Number of replicas | `1` |
| `resources.requests.cpu` | CPU request | `250m` |
| `resources.requests.memory` | Memory request | `384Mi` |
| `resources.limits.cpu` | CPU limit | `1` |
| `resources.limits.memory` | Memory limit | `768Mi` |
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `5` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization | `75` |
| `podDisruptionBudget.enabled` | Enable PDB | `false` |
| `podDisruptionBudget.minAvailable` | Minimum available pods | `1` |

### Other

| Parameter | Description | Default |
|---|---|---|
| `serviceAccount.create` | Create a service account | `true` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |

## What's Included

- **Deployment** with health probes (liveness, readiness, startup), read-only root filesystem, non-root user
- **Service** (ClusterIP)
- **Ingress** (optional, supports cert-manager TLS)
- **ConfigMap** for application configuration
- **Secret** (chart-managed or reference existing)
- **ServiceAccount** (optional)
- **HPA** (optional)
- **PodDisruptionBudget** (optional)

## Database Migrations

CasePack API uses Flyway for database migrations. Migrations run automatically on startup — no manual steps required. Ensure the database user has `CREATE TABLE` privileges on first deploy.

## Licensing

A valid license token is required to start CasePack. Obtain a license from [bysam.io](https://licensing.bysam.io) and set `CASEPACK_LICENSE_TOKEN` in your secret. For SaaS deployments using JWKS, configure `CASEPACK_LICENSE_KEY_SOURCE=jwks` and `CASEPACK_LICENSE_JWKS_URL`; do not include `CASEPACK_LICENSE_PUBLIC_KEY` unless you intentionally need an env-var fallback verifier.

## Support

- Documentation: [https://docs.casepack.app](https://docs.casepack.app)
- Issues: [https://github.com/bysamio/casepack-api/issues](https://github.com/bysamio/casepack-api/issues)
