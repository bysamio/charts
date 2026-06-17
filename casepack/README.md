# CasePack Helm Chart

Umbrella Helm chart that deploys the full CasePack stack — API, SPA, PostgreSQL, Keycloak, and SeaweedFS — in a single command.

## Quick Start

```bash
helm repo add bysamio https://bysamio.github.io/charts/
helm repo update

helm upgrade --install casepack bysamio/casepack \
  --namespace casepack \
  --create-namespace
```

This installs CasePack with all bundled infrastructure using default dev credentials. **Not suitable for production without overrides.**

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   CasePack Umbrella Chart                    │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │ casepack-api │  │ casepack-spa │  │    postgresql     │  │
│  │  (subchart)  │  │  (subchart)  │  │    (subchart)     │  │
│  └──────┬───────┘  └──────────────┘  └────────┬─────────┘  │
│         │                                      │            │
│         ├──── OIDC auth ──┐                    │            │
│         ├──── JDBC ───────┼────────────────────┘            │
│         │                 │                                 │
│  ┌──────┴───────┐  ┌─────┴──────┐                          │
│  │  seaweedfs   │  │  keycloak  │                          │
│  │  (subchart)  │  │ (subchart) │                          │
│  └──────────────┘  └────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

## Subcharts

| Component | Chart | Version | Condition |
|---|---|---|---|
| CasePack API | `casepack-api` | `0.19.0` | Always enabled |
| CasePack SPA | `casepack-spa` | `0.18.0` | `casepack-spa.enabled` |
| PostgreSQL | `postgresql` (BySamio) | `2.3.1` | `postgresql.enabled` |
| Keycloak | `keycloak` (BySamio) | `1.2.4` | `keycloak.enabled` |
| SeaweedFS | `seaweedfs` | `4.34.0` | `seaweedfs.enabled` |

## Self-Host License Setup

Run `./activate.sh <activation-token>` first. It writes `license.jwt`, `activation.json`,
and the self-host values in `.env`.

For Kubernetes, provide self-host runtime values through a Kubernetes Secret
referenced by `casepack-api.secrets.existingSecret`. Create the env file outside
git:

```bash
cat > /tmp/casepack-api-selfhost.env <<'EOF'
DB_URL=jdbc:postgresql://casepack-postgresql-primary:5432/casepack
DB_USER=casepack
DB_PASS=change-me
S3_ACCESS_KEY=admin
S3_SECRET_KEY=admin123456
S3_PUBLIC_ENDPOINT=https://s3.casepack.example.com
CASEPACK_LICENSE_TOKEN=<contents-of-license.jwt>
CASEPACK_LICENSE_KEY_SOURCE=jwks
CASEPACK_LICENSE_JWKS_URL=https://licensing.bysam.io/.well-known/jwks.json
CASEPACK_DEPLOYMENT_MODE=self_host
CASEPACK_INSTALLATION_ID=inst_your-installation-id
CASEPACK_SELF_HOST_BOOTSTRAP_ENABLED=true
CASEPACK_SELF_HOST_BOOTSTRAP_TENANT_NAME=CasePack Workspace
CASEPACK_SELF_HOST_BOOTSTRAP_ADMIN_EMAIL=owner@example.com
CASEPACK_SELF_HOST_BOOTSTRAP_ADMIN_INITIAL_PASSWORD=change-me-on-first-login
CASEPACK_KEYCLOAK_BASE_URL=http://casepack-keycloak
CASEPACK_KEYCLOAK_REALM=casepack
CASEPACK_KEYCLOAK_SPA_CLIENT_ID=casepack-spa
CASEPACK_KEYCLOAK_SPA_REDIRECT_URI=http://localhost:3000/auth/callback
CASEPACK_KEYCLOAK_SA_CLIENT_ID=casepack-user-manager
CASEPACK_KEYCLOAK_SA_CLIENT_SECRET=casepack-user-manager-secret
EOF

kubectl create secret generic casepack-api-selfhost \
  --namespace casepack \
  --from-env-file=/tmp/casepack-api-selfhost.env
```

Then install with:

```yaml
casepack-api:
  secrets:
    existingSecret: "casepack-api-selfhost"
```

The Docker Compose path mounts `license.jwt` and `activation.json` directly. For
Kubernetes, keep those files outside git and project the required values into
the API Secret.

### Renewal

For Kubernetes, run `./renew-license.sh --no-restart`, update the license secret, then restart the API deployment:

```bash
kubectl create secret generic casepack-api-selfhost \
  --namespace casepack \
  --from-env-file=/tmp/casepack-api-selfhost.env \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl rollout restart deployment/casepack-casepack-api -n casepack
```

## Production Deployment

Disable bundled infrastructure and point to managed services:

```yaml
# production-values.yaml
postgresql:
  enabled: false

keycloak:
  enabled: false

seaweedfs:
  enabled: false

casepack-api:
  secrets:
    existingSecret: "casepack-api-secrets"
  config:
    oidcIssuerUri: "https://auth.example.com/realms/casepack"
    s3Endpoint: "http://object-store.internal:8333"
    s3PublicEndpoint: "https://s3.casepack.example.com"
    s3Region: "eu-central-1"
    s3PathStyle: "true"
    corsOrigins: "https://casepack.example.com"
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

```bash
helm upgrade --install casepack bysamio/casepack \
  --namespace casepack \
  --create-namespace \
  -f production-values.yaml
```

## Parameters

### Global

| Parameter | Description | Default |
|---|---|---|
| `global.domain` | Base domain for subcharts | `casepack.example.com` |
| `global.storageClass` | StorageClass for all PVCs | `""` (cluster default) |

### CasePack API (`casepack-api.*`)

| Parameter | Description | Default |
|---|---|---|
| `casepack-api.replicaCount` | Number of API replicas | `1` |
| `casepack-api.image.repository` | API image repository | `ghcr.io/bysamio/casepack-api` |
| `casepack-api.image.tag` | API image tag | `""` (chart appVersion) |
| `casepack-api.config.oidcIssuerUri` | OIDC issuer URI | `http://casepack-keycloak/realms/casepack` |
| `casepack-api.config.s3Endpoint` | Internal S3 endpoint used by API server-side storage operations | `http://casepack-seaweedfs-s3:8333` |
| `casepack-api.config.s3PublicEndpoint` | Optional browser-facing S3 endpoint for presigned URLs; include `S3_PUBLIC_ENDPOINT` in `existingSecret` when using the Secret path | `""` |
| `casepack-api.config.corsOrigins` | CORS allowed origins | `http://localhost:3000` |
| `casepack-api.config.deploymentMode` | Deployment mode; include `CASEPACK_DEPLOYMENT_MODE` in `existingSecret` when using the Secret path | `self_host` |
| `casepack-api.config.installationId` | Installation ID; include `CASEPACK_INSTALLATION_ID` in `existingSecret` when using the Secret path | `""` |
| `casepack-api.config.licenseKeySource` | License key source | `jwks` |
| `casepack-api.config.licenseJwksUrl` | Licensing JWKS URL | `https://licensing.bysam.io/.well-known/jwks.json` |
| `casepack-api.config.activationFile` | Activation bundle path when mounted as a file | `/run/secrets/activation.json` |
| `casepack-api.config.selfHostBootstrapEnabled` | Bootstrap toggle; include `CASEPACK_SELF_HOST_BOOTSTRAP_ENABLED` in `existingSecret` when using the Secret path | `true` |
| `casepack-api.config.selfHostBootstrapTenantName` | Initial tenant name; include `CASEPACK_SELF_HOST_BOOTSTRAP_TENANT_NAME` in `existingSecret` when using the Secret path | `CasePack Workspace` |
| `casepack-api.config.selfHostBootstrapAdminEmail` | Bootstrap admin email; include `CASEPACK_SELF_HOST_BOOTSTRAP_ADMIN_EMAIL` in `existingSecret` when using the Secret path | `""` |
| `casepack-api.config.selfHostBootstrapAdminInitialPassword` | Bootstrap admin initial password; include `CASEPACK_SELF_HOST_BOOTSTRAP_ADMIN_INITIAL_PASSWORD` in `existingSecret` when using the Secret path | `""` |
| `casepack-api.secrets.existingSecret` | Use pre-created K8s Secret | `""` |
| `casepack-api.secrets.dbUrl` | PostgreSQL JDBC URL | `jdbc:postgresql://casepack-postgresql-primary:5432/casepack` |
| `casepack-api.secrets.dbPass` | Database password | `casepack` |
| `casepack-api.secrets.licenseToken` | Inline license JWT as `CASEPACK_LICENSE_TOKEN` | `""` |
| `casepack-api.secrets.licenseTokenFile` | Helper value for rendering a wrapper-owned `license.jwt` Secret | `""` |
| `casepack-api.secrets.activationBundle` | Helper value for rendering a wrapper-owned `activation.json` Secret | `""` |
| `casepack-api.ingress.enabled` | Enable API Ingress | `false` |

### CasePack SPA (`casepack-spa.*`)

| Parameter | Description | Default |
|---|---|---|
| `casepack-spa.enabled` | Deploy bundled SPA | `true` |
| `casepack-spa.replicaCount` | Number of SPA replicas | `1` |
| `casepack-spa.image.repository` | SPA image repository | `ghcr.io/bysamio/casepack-spa` |
| `casepack-spa.config.apiBaseUrl` | API base URL | `http://localhost:8080` |
| `casepack-spa.config.oidcAuthority` | OIDC authority URL | `http://localhost:8081/realms/casepack` |
| `casepack-spa.config.deploymentMode` | SPA deployment mode | `SELF_HOST` |
| `casepack-spa.config.licensingPortalUrl` | Licensing portal URL | `https://licensing.bysam.io/portal` |
| `casepack-spa.ingress.enabled` | Enable SPA Ingress | `false` |

### PostgreSQL (`postgresql.*`)

| Parameter | Description | Default |
|---|---|---|
| `postgresql.enabled` | Deploy bundled PostgreSQL | `true` |
| `postgresql.auth.database` | Database name | `casepack` |
| `postgresql.auth.username` | Database user | `casepack` |
| `postgresql.auth.password` | Database password | `casepack` |
| `postgresql.auth.postgresPassword` | Superuser password | `postgres` |
| `postgresql.primary.persistence.size` | PVC size | `10Gi` |

### Keycloak (`keycloak.*`)

| Parameter | Description | Default |
|---|---|---|
| `keycloak.enabled` | Deploy bundled Keycloak | `true` |
| `keycloak.auth.adminUser` | Admin username | `admin` |
| `keycloak.auth.adminPassword` | Admin password | `admin` |
| `keycloak.database.host` | Database host | `casepack-postgresql` |
| `keycloak.database.database` | Database name | `keycloak` |
| `keycloak.database.user` | Database user | `keycloak` |
| `keycloak.database.password` | Database password | `keycloak` |
| `keycloak.ingress.enabled` | Enable Keycloak Ingress | `false` |

### SeaweedFS (`seaweedfs.*`)

| Parameter | Description | Default |
|---|---|---|
| `seaweedfs.enabled` | Deploy bundled SeaweedFS | `true` |
| `seaweedfs.image.repository` | Image repository | `chrislusf/seaweedfs` |
| `seaweedfs.image.tag` | Image tag | `latest` |
| `seaweedfs.s3.port` | S3 gateway port | `8333` |
| `seaweedfs.persistence.size` | PVC size | `10Gi` |

## Keycloak Database Init

When both `postgresql.enabled` and `keycloak.enabled` are `true`, the chart deploys a `post-install` Job that creates the `keycloak` database and user in the bundled PostgreSQL instance.

## Upgrade

```bash
helm upgrade casepack bysamio/casepack \
  --namespace casepack \
  -f your-values.yaml
```

## Uninstall

```bash
helm uninstall casepack --namespace casepack
```

> **Note:** PVCs for PostgreSQL and SeaweedFS are retained after uninstall. Delete them manually if you want a clean slate:
> ```bash
> kubectl delete pvc -l app.kubernetes.io/instance=casepack -n casepack
> ```

## Standalone Charts

| Chart | Helm Repo |
|---|---|
| CasePack API | `bysamio/casepack-api` |
| CasePack SPA | `bysamio/casepack-spa` |
| Keycloak | `bysamio/keycloak` |
| SeaweedFS | `bysamio/seaweedfs` |
| PostgreSQL | `bysamio/postgresql` |

## Support

- [CasePack Deployment Guide](https://github.com/bysamio/casepack)
- [BySamio Charts](https://github.com/bysamio/charts)
