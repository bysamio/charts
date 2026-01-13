# WordPress Helm Chart

A production-ready Helm chart for deploying WordPress on Kubernetes using the official WordPress Docker image. This chart provides automatic WordPress installation, high availability, security best practices, and integration with MariaDB and Memcached for optimal performance.

## Overview

This Helm chart deploys WordPress on Kubernetes with the following features:

- **Official WordPress Image**: Uses the official `wordpress:6.9.0-apache` Docker image
- **Automatic Installation**: Automatically installs WordPress using wp-cli, eliminating the need for manual web-based setup
- **High Availability**: Supports multiple replicas with rolling updates for zero-downtime deployments
- **Database Integration**: Integrated MariaDB subchart for database management
- **Caching**: Optional Memcached integration for improved performance
- **Security**: Production-ready security contexts, network policies, and secret management
- **Flexibility**: Supports external databases, custom PHP configuration, SMTP configuration, and more
- **Compatibility**: Works with Minikube, MicroK8s, and production Kubernetes clusters

## Quick Start

```bash
# Install with default values
helm install my-wordpress .

# Install with custom values
helm install my-wordpress . -f values-production.yaml

# Upgrade existing installation
helm upgrade my-wordpress . -f values-production.yaml
```

## Configuration

The following tables document all available configuration options in `values.yaml`. Each section corresponds to a logical grouping of related parameters.

---

## Global Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `global.imageRegistry` | string | `""` | Global Docker image registry override |
| `global.imagePullSecrets` | array | `[]` | Global Docker registry secret names |
| `global.defaultStorageClass` | string | `""` | Default storage class for dynamic provisioning |

---

## Common Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `nameOverride` | string | `""` | Override the name of the chart |
| `fullnameOverride` | string | `""` | Override the full name of the chart |
| `commonLabels` | object | `{}` | Labels to add to all resources |
| `commonAnnotations` | object | `{}` | Annotations to add to all resources |
| `clusterDomain` | string | `"cluster.local"` | Kubernetes cluster domain |
| `extraDeploy` | array | `[]` | Extra Kubernetes resources to deploy |

---

## WordPress Image Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `image.registry` | string | `"docker.io"` | Docker image registry |
| `image.repository` | string | `"wordpress"` | Docker image repository |
| `image.tag` | string | `"6.9.0-apache"` | Docker image tag |
| `image.digest` | string | `""` | Docker image digest (for immutable images) |
| `image.pullPolicy` | string | `"IfNotPresent"` | Image pull policy (`Always`, `IfNotPresent`, `Never`) |
| `image.pullSecrets` | array | `[]` | Docker registry secret names |
| `image.debug` | boolean | `false` | Enable debug mode |

---

## WordPress Diagnostic Mode

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `diagnosticMode.enabled` | boolean | `false` | Enable diagnostic mode (disables probes, overrides command) |
| `diagnosticMode.command` | array | `["sleep"]` | Command to override all containers |
| `diagnosticMode.args` | array | `["infinity"]` | Args to override all containers |

---

## WordPress Configuration Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `wordpressUsername` | string | `"user"` | WordPress admin username |
| `wordpressPassword` | string | `""` | WordPress admin password (or key name if `existingSecret` is set) |
| `existingSecret` | string | `""` | Existing secret name for WordPress password |
| `wordpressEmail` | string | `"user@example.com"` | WordPress admin email |
| `wordpressFirstName` | string | `"FirstName"` | WordPress admin first name |
| `wordpressLastName` | string | `"LastName"` | WordPress admin last name |
| `wordpressBlogName` | string | `"User's Blog!"` | WordPress site title |
| `wordpressTablePrefix` | string | `"wp_"` | WordPress database table prefix |
| `wordpressScheme` | string | `"http"` | WordPress site scheme (`http` or `https`) |
| `wordpressSiteUrl` | string | `""` | WordPress site URL (auto-detected if empty) |
| `wordpressSkipInstall` | boolean | `false` | Skip automatic installation (use web installer) |
| `wordpressExtraConfigContent` | string | `""` | Extra WordPress configuration content |
| `wordpressConfiguration` | string | `""` | WordPress configuration file content |
| `existingWordPressConfigurationSecret` | string | `""` | Existing secret for WordPress configuration |
| `wordpressDebug` | boolean | `false` | Enable WordPress debug mode (`WP_DEBUG`) |
| `wordpressConfigExtra` | string | `""` | Extra WordPress config (evaluated by `eval()` in wp-config.php) |
| `wordpressEnableMemcached` | boolean | `true` | Enable Memcached environment variables |
| `wordpressAuthKey` | string | `""` | WordPress authentication key (auto-generated if empty) |
| `wordpressSecureAuthKey` | string | `""` | WordPress secure authentication key |
| `wordpressLoggedInKey` | string | `""` | WordPress logged-in key |
| `wordpressNonceKey` | string | `""` | WordPress nonce key |
| `wordpressAuthSalt` | string | `""` | WordPress authentication salt |
| `wordpressSecureAuthSalt` | string | `""` | WordPress secure authentication salt |
| `wordpressLoggedInSalt` | string | `""` | WordPress logged-in salt |
| `wordpressNonceSalt` | string | `""` | WordPress nonce salt |
| `wordpressConfigureCache` | boolean | `false` | Configure WordPress cache |
| `wordpressPlugins` | string | `"none"` | WordPress plugins to install |
| `apacheConfiguration` | string | `""` | Apache configuration content |
| `existingApacheConfigurationConfigMap` | string | `""` | Existing ConfigMap for Apache configuration |
| `customPostInitScripts` | object | `{}` | Custom post-init scripts |

**Note on `wordpressPassword` and `existingSecret`**:
- When `existingSecret` is set: `wordpressPassword` value is used as the **key name** in the secret
- When `existingSecret` is NOT set: `wordpressPassword` value is the **actual password** (stored in auto-generated secret)

---

## PHP Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `phpConfiguration.enabled` | boolean | `false` | Enable PHP configuration via ConfigMap |
| `phpConfiguration.configMapName` | string | `""` | ConfigMap name (defaults to chart-generated name) |
| `phpConfiguration.customIniFileName` | string | `"php-custom.ini"` | Name of the .ini file in the ConfigMap |
| `phpConfiguration.uploadMaxFilesize` | string | `""` | Maximum upload file size (e.g., `"256M"`) |
| `phpConfiguration.postMaxSize` | string | `""` | Maximum POST size (e.g., `"256M"`) |
| `phpConfiguration.maxExecutionTime` | string | `""` | Maximum execution time in seconds (e.g., `360`) |
| `phpConfiguration.maxInputTime` | string | `""` | Maximum input time in seconds (e.g., `360`) |
| `phpConfiguration.memoryLimit` | string | `""` | PHP memory limit (e.g., `"512M"`) |
| `phpConfiguration.maxInputVars` | string | `""` | Maximum input variables (e.g., `3000`) |
| `phpConfiguration.uploadTmpDir` | string | `""` | Custom upload temporary directory |
| `phpConfiguration.additionalSettings` | string | `""` | Additional PHP settings (appended to ini file) |
| `phpConfiguration.customIni` | string | `""` | Complete PHP ini content (overrides individual settings) |
| `phpConfiguration.labels` | object | `{}` | Additional labels for the ConfigMap |

---

## SMTP Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `smtpHost` | string | `""` | SMTP server hostname |
| `smtpPort` | string | `""` | SMTP server port |
| `smtpUser` | string | `""` | SMTP username |
| `smtpPassword` | string | `""` | SMTP password (or key name if `smtpExistingSecret` is set) |
| `smtpProtocol` | string | `""` | SMTP protocol (`tls`, `ssl`, etc.) |
| `smtpFromEmail` | string | `""` | SMTP from email address |
| `smtpFromName` | string | `""` | SMTP from name |
| `smtpExistingSecret` | string | `""` | Existing secret name for SMTP password |

**Note on `smtpPassword` and `smtpExistingSecret`**:
- When `smtpExistingSecret` is set: `smtpPassword` value is used as the **key name** in the secret
- When `smtpExistingSecret` is NOT set: `smtpPassword` value is the **actual password** (stored in auto-generated secret)

---

## Security Settings

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `allowEmptyPassword` | boolean | `false` | Allow empty passwords (not recommended for production) |
| `allowOverrideNone` | boolean | `false` | Disable .htaccess overrides |
| `overrideDatabaseSettings` | boolean | `false` | Override database settings |
| `htaccessPersistenceEnabled` | boolean | `false` | Enable .htaccess persistence |
| `customHTAccessCM` | string | `""` | Custom .htaccess ConfigMap |

---

## Environment Variables

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `command` | array | `[]` | Override default container command |
| `args` | array | `[]` | Override default container args |
| `extraEnvVars` | array | `[]` | Extra environment variables |
| `extraEnvVarsCM` | string | `""` | ConfigMap name for extra environment variables |
| `extraEnvVarsSecret` | string | `""` | Secret name for extra environment variables |

---

## WordPress Multisite Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `multisite.enable` | boolean | `false` | Enable WordPress multisite |
| `multisite.host` | string | `""` | Multisite hostname |
| `multisite.networkType` | string | `"subdomain"` | Multisite network type (`subdomain` or `subdirectory`) |
| `multisite.enableNipIoRedirect` | boolean | `false` | Enable .nip.io redirect for multisite |

---

## Deployment Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `replicaCount` | integer | `1` | Number of WordPress replicas (set to 2+ for HA) |
| `updateStrategy.type` | string | `"RollingUpdate"` | Deployment update strategy |
| `updateStrategy.rollingUpdate.maxSurge` | string | `""` | Maximum number of pods that can be created during update (default: 1) |
| `updateStrategy.rollingUpdate.maxUnavailable` | string | `""` | Maximum number of pods that can be unavailable during update (default: 0) |
| `schedulerName` | string | `""` | Custom Kubernetes scheduler name |
| `terminationGracePeriodSeconds` | integer | `""` | Pod termination grace period in seconds |
| `topologySpreadConstraints` | array | `[]` | Topology spread constraints |
| `priorityClassName` | string | `""` | Pod priority class name |
| `automountServiceAccountToken` | boolean | `false` | Automount service account token |
| `hostAliases` | array | `[]` | Host aliases for pods |
| `extraVolumes` | array | `[]` | Extra volumes to mount |
| `extraVolumeMounts` | array | `[]` | Extra volume mounts |
| `sidecars` | array | `[]` | Sidecar containers |
| `initContainers` | array | `[]` | Init containers |
| `podLabels` | object | `{}` | Additional pod labels |
| `podAnnotations` | object | `{}` | Additional pod annotations |
| `podAffinityPreset` | string | `""` | Pod affinity preset |
| `nodeAffinityPreset.type` | string | `""` | Node affinity preset type |
| `nodeAffinityPreset.key` | string | `""` | Node affinity preset key |
| `nodeAffinityPreset.values` | array | `[]` | Node affinity preset values |
| `affinity` | object | `{}` | Custom affinity rules |
| `nodeSelector` | object | `{}` | Node selector |
| `tolerations` | array | `[]` | Pod tolerations |
| `resourcesPreset` | string | `"micro"` | Resource preset (`nano`, `micro`, `small`, `medium`, `large`) |
| `resources.limits` | object | `{}` | Resource limits (CPU, memory) |
| `resources.requests` | object | `{}` | Resource requests (CPU, memory) |

---

## Container Ports

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `containerPorts.http` | integer | `80` | HTTP container port |
| `containerPorts.https` | integer | `443` | HTTPS container port |
| `extraContainerPorts` | array | `[]` | Extra container ports |

---

## Security Context

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `podSecurityContext.enabled` | boolean | `true` | Enable pod security context |
| `podSecurityContext.fsGroupChangePolicy` | string | `"Always"` | FSGroup change policy |
| `podSecurityContext.sysctls` | array | `[]` | Sysctls |
| `podSecurityContext.supplementalGroups` | array | `[]` | Supplemental groups |
| `podSecurityContext.fsGroup` | integer | `33` | FSGroup (www-data group) |
| `containerSecurityContext.enabled` | boolean | `true` | Enable container security context |
| `containerSecurityContext.seLinuxOptions` | object | `{}` | SELinux options |
| `containerSecurityContext.runAsUser` | integer | `33` | Run as user (www-data) |
| `containerSecurityContext.runAsGroup` | integer | `33` | Run as group (www-data) |
| `containerSecurityContext.runAsNonRoot` | boolean | `true` | Run as non-root user |
| `containerSecurityContext.privileged` | boolean | `false` | Run in privileged mode |
| `containerSecurityContext.readOnlyRootFilesystem` | boolean | `false` | Read-only root filesystem |
| `containerSecurityContext.allowPrivilegeEscalation` | boolean | `false` | Allow privilege escalation |
| `containerSecurityContext.capabilities.drop` | array | `["ALL"]` | Capabilities to drop |
| `containerSecurityContext.seccompProfile.type` | string | `"RuntimeDefault"` | Seccomp profile type |

---

## Health Probes

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `livenessProbe.enabled` | boolean | `true` | Enable liveness probe |
| `livenessProbe.httpGet.path` | string | `"/wp-admin/install.php"` | Liveness probe path |
| `livenessProbe.httpGet.port` | string | `"http"` | Liveness probe port |
| `livenessProbe.httpGet.scheme` | string | `"HTTP"` | Liveness probe scheme |
| `livenessProbe.initialDelaySeconds` | integer | `120` | Liveness probe initial delay |
| `livenessProbe.periodSeconds` | integer | `10` | Liveness probe period |
| `livenessProbe.timeoutSeconds` | integer | `5` | Liveness probe timeout |
| `livenessProbe.failureThreshold` | integer | `6` | Liveness probe failure threshold |
| `livenessProbe.successThreshold` | integer | `1` | Liveness probe success threshold |
| `readinessProbe.enabled` | boolean | `true` | Enable readiness probe |
| `readinessProbe.httpGet.path` | string | `"/wp-login.php"` | Readiness probe path |
| `readinessProbe.httpGet.port` | string | `"http"` | Readiness probe port |
| `readinessProbe.httpGet.scheme` | string | `"HTTP"` | Readiness probe scheme |
| `readinessProbe.initialDelaySeconds` | integer | `30` | Readiness probe initial delay |
| `readinessProbe.periodSeconds` | integer | `10` | Readiness probe period |
| `readinessProbe.timeoutSeconds` | integer | `5` | Readiness probe timeout |
| `readinessProbe.failureThreshold` | integer | `6` | Readiness probe failure threshold |
| `readinessProbe.successThreshold` | integer | `1` | Readiness probe success threshold |
| `startupProbe.enabled` | boolean | `false` | Enable startup probe |
| `startupProbe.httpGet.path` | string | `"/wp-login.php"` | Startup probe path |
| `startupProbe.httpGet.port` | string | `"http"` | Startup probe port |
| `startupProbe.httpGet.scheme` | string | `"HTTP"` | Startup probe scheme |
| `startupProbe.initialDelaySeconds` | integer | `30` | Startup probe initial delay |
| `startupProbe.periodSeconds` | integer | `10` | Startup probe period |
| `startupProbe.timeoutSeconds` | integer | `5` | Startup probe timeout |
| `startupProbe.failureThreshold` | integer | `6` | Startup probe failure threshold |
| `startupProbe.successThreshold` | integer | `1` | Startup probe success threshold |
| `customLivenessProbe` | object | `{}` | Custom liveness probe configuration |
| `customReadinessProbe` | object | `{}` | Custom readiness probe configuration |
| `customStartupProbe` | object | `{}` | Custom startup probe configuration |
| `lifecycleHooks` | object | `{}` | Container lifecycle hooks |

---

## Service Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `service.type` | string | `"LoadBalancer"` | Service type (`ClusterIP`, `NodePort`, `LoadBalancer`) |
| `service.ports.http` | integer | `80` | HTTP service port |
| `service.ports.https` | integer | `443` | HTTPS service port |
| `service.httpsTargetPort` | string | `"https"` | HTTPS target port |
| `service.nodePorts.http` | string | `""` | HTTP node port |
| `service.nodePorts.https` | string | `""` | HTTPS node port |
| `service.sessionAffinity` | string | `"None"` | Session affinity |
| `service.sessionAffinityConfig` | object | `{}` | Session affinity configuration |
| `service.clusterIP` | string | `""` | Cluster IP address |
| `service.loadBalancerIP` | string | `""` | Load balancer IP address |
| `service.loadBalancerSourceRanges` | array | `[]` | Load balancer source ranges |
| `service.externalTrafficPolicy` | string | `"Cluster"` | External traffic policy |
| `service.annotations` | object | `{}` | Service annotations |
| `service.extraPorts` | array | `[]` | Extra service ports |

---

## Ingress Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ingress.enabled` | boolean | `false` | Enable ingress |
| `ingress.pathType` | string | `"ImplementationSpecific"` | Ingress path type |
| `ingress.apiVersion` | string | `""` | Ingress API version |
| `ingress.ingressClassName` | string | `""` | Ingress class name |
| `ingress.hostname` | string | `"wordpress.local"` | Ingress hostname |
| `ingress.path` | string | `"/"` | Ingress path |
| `ingress.annotations` | object | `{}` | Ingress annotations |
| `ingress.tls` | boolean | `false` | Enable TLS |
| `ingress.tlsWwwPrefix` | boolean | `false` | Enable www prefix for TLS |
| `ingress.selfSigned` | boolean | `false` | Use self-signed certificate |
| `ingress.extraHosts` | array | `[]` | Extra ingress hosts |
| `ingress.extraPaths` | array | `[]` | Extra ingress paths |
| `ingress.extraTls` | array | `[]` | Extra TLS configurations |
| `ingress.secrets` | array | `[]` | TLS secrets |
| `ingress.extraRules` | array | `[]` | Extra ingress rules |
| `secondaryIngress.enabled` | boolean | `false` | Enable secondary ingress |
| `secondaryIngress.pathType` | string | `"ImplementationSpecific"` | Secondary ingress path type |
| `secondaryIngress.apiVersion` | string | `""` | Secondary ingress API version |
| `secondaryIngress.ingressClassName` | string | `""` | Secondary ingress class name |
| `secondaryIngress.hostname` | string | `"wordpress.local"` | Secondary ingress hostname |
| `secondaryIngress.path` | string | `"/"` | Secondary ingress path |
| `secondaryIngress.annotations` | object | `{}` | Secondary ingress annotations |
| `secondaryIngress.tls` | boolean | `false` | Enable TLS for secondary ingress |
| `secondaryIngress.tlsWwwPrefix` | boolean | `false` | Enable www prefix for secondary ingress TLS |
| `secondaryIngress.selfSigned` | boolean | `false` | Use self-signed certificate for secondary ingress |
| `secondaryIngress.extraHosts` | array | `[]` | Extra secondary ingress hosts |
| `secondaryIngress.extraPaths` | array | `[]` | Extra secondary ingress paths |
| `secondaryIngress.extraTls` | array | `[]` | Extra TLS configurations for secondary ingress |
| `secondaryIngress.secrets` | array | `[]` | TLS secrets for secondary ingress |
| `secondaryIngress.extraRules` | array | `[]` | Extra rules for secondary ingress |

---

## Persistence Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `persistence.enabled` | boolean | `true` | Enable persistent volume |
| `persistence.storageClass` | string | `""` | Storage class (empty uses default) |
| `persistence.accessModes` | array | `["ReadWriteOnce"]` | Access modes |
| `persistence.size` | string | `"10Gi"` | Persistent volume size |
| `persistence.dataSource` | object | `{}` | Data source for volume |
| `persistence.existingClaim` | string | `""` | Existing PVC name |
| `persistence.selector` | object | `{}` | PVC selector |
| `persistence.annotations` | object | `{}` | PVC annotations |

---

## Volume Permissions

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `volumePermissions.enabled` | boolean | `false` | Enable volume permissions init container |
| `volumePermissions.image.registry` | string | `"docker.io"` | Volume permissions image registry |
| `volumePermissions.image.repository` | string | `"alpine"` | Volume permissions image repository |
| `volumePermissions.image.tag` | string | `"3.22.1"` | Volume permissions image tag |
| `volumePermissions.image.digest` | string | `""` | Volume permissions image digest |
| `volumePermissions.image.pullPolicy` | string | `"IfNotPresent"` | Volume permissions image pull policy |
| `volumePermissions.image.pullSecrets` | array | `[]` | Volume permissions image pull secrets |
| `volumePermissions.resourcesPreset` | string | `"nano"` | Volume permissions resource preset |
| `volumePermissions.resources` | object | `{}` | Volume permissions resource limits/requests |
| `volumePermissions.containerSecurityContext.runAsUser` | integer | `0` | Volume permissions run as user (root) |

---

## Service Account

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `serviceAccount.create` | boolean | `true` | Create service account |
| `serviceAccount.name` | string | `""` | Service account name |
| `serviceAccount.automountServiceAccountToken` | boolean | `false` | Automount service account token |
| `serviceAccount.annotations` | object | `{}` | Service account annotations |

---

## Pod Disruption Budget

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pdb.create` | boolean | `true` | Create Pod Disruption Budget |
| `pdb.minAvailable` | string | `""` | Minimum available pods (e.g., `"50%"` or `1`) |
| `pdb.maxUnavailable` | string | `""` | Maximum unavailable pods (e.g., `"25%"`) |

---

## Autoscaling (HPA)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `autoscaling.enabled` | boolean | `false` | Enable Horizontal Pod Autoscaler |
| `autoscaling.minReplicas` | integer | `1` | Minimum number of replicas |
| `autoscaling.maxReplicas` | integer | `11` | Maximum number of replicas |
| `autoscaling.targetCPU` | integer | `50` | Target CPU utilization percentage |
| `autoscaling.targetMemory` | integer | `50` | Target memory utilization percentage |

---

## Metrics Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `metrics.enabled` | boolean | `false` | Enable metrics collection |
| `metrics.image.registry` | string | `"docker.io"` | Metrics image registry |
| `metrics.image.repository` | string | `"lusotycoon/apache-exporter"` | Metrics image repository |
| `metrics.image.tag` | string | `"v1.0.10"` | Metrics image tag |
| `metrics.image.digest` | string | `""` | Metrics image digest |
| `metrics.image.pullPolicy` | string | `"IfNotPresent"` | Metrics image pull policy |
| `metrics.image.pullSecrets` | array | `[]` | Metrics image pull secrets |
| `metrics.containerPorts.metrics` | integer | `9117` | Metrics container port |
| `metrics.livenessProbe.enabled` | boolean | `true` | Enable metrics liveness probe |
| `metrics.livenessProbe.initialDelaySeconds` | integer | `15` | Metrics liveness probe initial delay |
| `metrics.livenessProbe.periodSeconds` | integer | `10` | Metrics liveness probe period |
| `metrics.livenessProbe.timeoutSeconds` | integer | `5` | Metrics liveness probe timeout |
| `metrics.livenessProbe.failureThreshold` | integer | `3` | Metrics liveness probe failure threshold |
| `metrics.livenessProbe.successThreshold` | integer | `1` | Metrics liveness probe success threshold |
| `metrics.readinessProbe.enabled` | boolean | `true` | Enable metrics readiness probe |
| `metrics.readinessProbe.initialDelaySeconds` | integer | `5` | Metrics readiness probe initial delay |
| `metrics.readinessProbe.periodSeconds` | integer | `10` | Metrics readiness probe period |
| `metrics.readinessProbe.timeoutSeconds` | integer | `3` | Metrics readiness probe timeout |
| `metrics.readinessProbe.failureThreshold` | integer | `3` | Metrics readiness probe failure threshold |
| `metrics.readinessProbe.successThreshold` | integer | `1` | Metrics readiness probe success threshold |
| `metrics.startupProbe.enabled` | boolean | `false` | Enable metrics startup probe |
| `metrics.startupProbe.initialDelaySeconds` | integer | `10` | Metrics startup probe initial delay |
| `metrics.startupProbe.periodSeconds` | integer | `10` | Metrics startup probe period |
| `metrics.startupProbe.timeoutSeconds` | integer | `1` | Metrics startup probe timeout |
| `metrics.startupProbe.failureThreshold` | integer | `15` | Metrics startup probe failure threshold |
| `metrics.startupProbe.successThreshold` | integer | `1` | Metrics startup probe success threshold |
| `metrics.customLivenessProbe` | object | `{}` | Custom metrics liveness probe |
| `metrics.customReadinessProbe` | object | `{}` | Custom metrics readiness probe |
| `metrics.customStartupProbe` | object | `{}` | Custom metrics startup probe |
| `metrics.resourcesPreset` | string | `"nano"` | Metrics resource preset |
| `metrics.resources` | object | `{}` | Metrics resource limits/requests |
| `metrics.containerSecurityContext.enabled` | boolean | `true` | Enable metrics container security context |
| `metrics.containerSecurityContext.runAsUser` | integer | `1001` | Metrics container run as user |
| `metrics.containerSecurityContext.runAsGroup` | integer | `1001` | Metrics container run as group |
| `metrics.containerSecurityContext.runAsNonRoot` | boolean | `true` | Metrics container run as non-root |
| `metrics.containerSecurityContext.privileged` | boolean | `false` | Metrics container privileged mode |
| `metrics.containerSecurityContext.readOnlyRootFilesystem` | boolean | `true` | Metrics container read-only root filesystem |
| `metrics.containerSecurityContext.allowPrivilegeEscalation` | boolean | `false` | Metrics container allow privilege escalation |
| `metrics.containerSecurityContext.capabilities.drop` | array | `["ALL"]` | Metrics container capabilities to drop |
| `metrics.containerSecurityContext.seccompProfile.type` | string | `"RuntimeDefault"` | Metrics container seccomp profile type |
| `metrics.service.ports.metrics` | integer | `9150` | Metrics service port |
| `metrics.service.annotations` | object | `{}` | Metrics service annotations |
| `metrics.serviceMonitor.enabled` | boolean | `false` | Enable Prometheus ServiceMonitor |
| `metrics.serviceMonitor.namespace` | string | `""` | ServiceMonitor namespace |
| `metrics.serviceMonitor.interval` | string | `""` | ServiceMonitor scrape interval |
| `metrics.serviceMonitor.scrapeTimeout` | string | `""` | ServiceMonitor scrape timeout |
| `metrics.serviceMonitor.labels` | object | `{}` | ServiceMonitor labels |
| `metrics.serviceMonitor.selector` | object | `{}` | ServiceMonitor selector |
| `metrics.serviceMonitor.relabelings` | array | `[]` | ServiceMonitor relabelings |
| `metrics.serviceMonitor.metricRelabelings` | array | `[]` | ServiceMonitor metric relabelings |
| `metrics.serviceMonitor.honorLabels` | boolean | `false` | ServiceMonitor honor labels |
| `metrics.serviceMonitor.jobLabel` | string | `""` | ServiceMonitor job label |

---

## Network Policy

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `networkPolicy.enabled` | boolean | `true` | Enable NetworkPolicy |
| `networkPolicy.allowExternal` | boolean | `true` | Allow external ingress (set to `false` for production) |
| `networkPolicy.allowExternalEgress` | boolean | `true` | Allow external egress (set to `false` for production) |
| `networkPolicy.extraIngress` | array | `[]` | Extra ingress rules |
| `networkPolicy.extraEgress` | array | `[]` | Extra egress rules |
| `networkPolicy.ingressNSMatchLabels` | object | `{}` | Ingress namespace match labels |
| `networkPolicy.ingressNSPodMatchLabels` | object | `{}` | Ingress namespace pod match labels |

**Note**: NetworkPolicy controls **internal cluster traffic** (pod-to-pod), not external internet access. Your website remains publicly accessible via Ingress.

---

## MariaDB Configuration

The following are the most commonly used MariaDB configuration parameters. For the complete list of all available configurable values, see the [MariaDB chart values.yaml](https://github.com/bysamio/charts/blob/main/mariadb/values.yaml).

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `mariadb.enabled` | boolean | `true` | Enable MariaDB subchart |
| `mariadb.architecture` | string | `"standalone"` | MariaDB architecture |
| `mariadb.auth.rootPassword` | string | `""` | MariaDB root password |
| `mariadb.auth.database` | string | `"bysam_wordpress"` | MariaDB database name |
| `mariadb.auth.username` | string | `"bs_wordpress"` | MariaDB username |
| `mariadb.auth.password` | string | `""` | MariaDB user password |
| `mariadb.primary.persistence.enabled` | boolean | `true` | Enable MariaDB persistence |
| `mariadb.primary.persistence.storageClass` | string | `""` | MariaDB storage class |
| `mariadb.primary.persistence.accessModes` | array | `["ReadWriteOnce"]` | MariaDB access modes |
| `mariadb.primary.persistence.size` | string | `"8Gi"` | MariaDB persistent volume size |
| `mariadb.primary.resourcesPreset` | string | `"micro"` | MariaDB resource preset |
| `mariadb.primary.resources` | object | `{}` | MariaDB resource limits/requests |

---

## External Database Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `externalDatabase.host` | string | `"localhost"` | External database host |
| `externalDatabase.port` | integer | `3306` | External database port |
| `externalDatabase.user` | string | `"bn_wordpress"` | External database user |
| `externalDatabase.password` | string | `""` | External database password (or key name if `existingSecret` is set) |
| `externalDatabase.database` | string | `"bysam_wordpress"` | External database name |
| `externalDatabase.existingSecret` | string | `""` | Existing secret name for external database password |

**Note on `externalDatabase.password` and `existingSecret`**:
- When `existingSecret` is set: `password` value is used as the **key name** in the secret
- When `existingSecret` is NOT set: `password` value is the **actual password** (stored in auto-generated secret)

---

## Memcached Configuration

The following are the most commonly used Memcached configuration parameters. For the complete list of all available configurable values, see the [Memcached chart values.yaml](https://github.com/bysamio/charts/blob/main/memcached/values.yaml).

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `memcached.enabled` | boolean | `false` | Enable Memcached subchart |
| `memcached.auth.enabled` | boolean | `false` | Enable Memcached authentication |
| `memcached.auth.username` | string | `""` | Memcached username |
| `memcached.auth.password` | string | `""` | Memcached password |
| `memcached.auth.existingPasswordSecret` | string | `""` | Existing secret for Memcached password |
| `memcached.replicaCount` | integer | `1` | Memcached replica count |
| `memcached.resourcesPreset` | string | `"nano"` | Memcached resource preset |
| `memcached.resources` | object | `{}` | Memcached resource limits/requests |

---

## External Memcached Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `externalCache.host` | string | `"localhost"` | External Memcached host |
| `externalCache.port` | integer | `11211` | External Memcached port |

---

## Additional Resources

- [Production Checklist](PRODUCTION_CHECKLIST.md)
- [PHP Configuration Guide](PHP_CONFIGURATION.md)

---

## License

This chart is provided as-is. WordPress is licensed under GPLv2 or later.
