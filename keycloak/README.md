# Keycloak Helm Chart

A Helm chart for deploying [Keycloak](https://www.keycloak.org/) using BySamio hardened Docker images.

## Overview

This chart deploys Keycloak, an open-source Identity and Access Management solution, on Kubernetes. It uses BySamio's hardened container images that run as non-root (UID 1001) with security best practices.

## Features

- **Hardened Images**: Uses BySamio's security-hardened Keycloak images
- **Non-root Execution**: Runs as UID 1001 for enhanced security
- **Optimized Image Support**: Automatic detection of pre-built optimized images
- **PostgreSQL Integration**: Bundled PostgreSQL subchart for database
- **High Availability**: Support for clustered deployments with Infinispan caching
- **Metrics & Monitoring**: Prometheus ServiceMonitor and metrics endpoint
- **Security**: Network policies, PodDisruptionBudget, and securityContext configuration
- **Ingress**: Built-in ingress support with TLS

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8+
- PV provisioner support in the underlying infrastructure (for persistence)

## Installing the Chart

### From OCI Registry

```bash
helm install keycloak oci://ghcr.io/bysamio/charts/keycloak \
  --namespace keycloak \
  --create-namespace \
  --set auth.adminPassword=your-admin-password \
  --set postgresql.auth.postgresPassword=your-postgres-password \
  --set postgresql.auth.password=your-keycloak-db-password
```

### From Source

```bash
helm dependency update keycloak
helm install keycloak ./keycloak \
  --namespace keycloak \
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
| `global.security.allowInsecureImages` | boolean | `false` | Allows skipping image verification |
| `global.compatibility.openshift.adaptSecurityContext` | string | `"auto"` | Adapt the securityContext sections. Values: auto, force, disabled |

---

### Common Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `kubeVersion` | string | `""` | Override Kubernetes version reported by .Capabilities |
| `apiVersions` | array | `[]` | Override Kubernetes API versions reported by .Capabilities |
| `nameOverride` | string | `""` | String to partially override common.names.name |
| `fullnameOverride` | string | `""` | String to fully override common.names.fullname |
| `namespaceOverride` | string | `""` | String to fully override common.names.namespace |
| `commonLabels` | object | `{}` | Labels to add to all deployed objects |
| `commonAnnotations` | object | `{}` | Annotations to add to all deployed objects |
| `clusterDomain` | string | `"cluster.local"` | Default Kubernetes cluster domain |
| `extraDeploy` | array | `[]` | Array of extra objects to deploy with the release |
| `diagnosticMode.enabled` | boolean | `false` | Enable diagnostic mode (all probes disabled, command overridden) |
| `diagnosticMode.command` | array | `["sleep"]` | Command to override all containers in diagnostic mode |
| `diagnosticMode.args` | array | `["infinity"]` | Args to override all containers in diagnostic mode |
| `useHelmHooks` | boolean | `true` | Enable use of Helm hooks if needed (e.g., on post-install jobs) |
| `usePasswordFiles` | boolean | `true` | Mount credentials as files instead of environment variables |

---

### Image Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `image.registry` | string | `"ghcr.io"` | Keycloak image registry |
| `image.repository` | string | `"bysamio/keycloak"` | Keycloak image repository |
| `image.tag` | string | `"26.5.2"` | Keycloak image tag (immutable tags are recommended) |
| `image.digest` | string | `""` | Keycloak image digest (sha256:...). Overrides tag if set |
| `image.pullPolicy` | string | `"IfNotPresent"` | Keycloak image pull policy |
| `image.pullSecrets` | array | `[]` | Keycloak image pull secrets |
| `image.debug` | boolean | `false` | Enable Keycloak image debug mode |

**Image Types**: This chart supports two BySamio Keycloak images:
- **Flexible** (`26.5.2`): Alpine-based, can auto-build on startup
- **Optimized** (`26.5.2-optimized`): Distroless, pre-built, faster startup

The chart automatically detects optimized images by the `-optimized` suffix.

---

### Authentication Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `auth.adminUser` | string | `"user"` | Keycloak administrator username |
| `auth.adminPassword` | string | `""` | Keycloak administrator password (auto-generated if empty) |
| `auth.existingSecret` | string | `""` | Existing secret containing Keycloak admin password |
| `auth.passwordSecretKey` | string | `""` | Key in existing secret for admin password |
| `auth.annotations` | object | `{}` | Additional custom annotations for Keycloak auth secret object |

---

### Keycloak Configuration Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `production` | boolean | `false` | Run Keycloak in production mode (TLS required unless using proxy) |
| `httpRelativePath` | string | `"/"` | Path relative to '/' for serving resources |
| `proxyHeaders` | string | `""` | Proxy headers configuration |
| `configuration` | string | `""` | Keycloak configuration (auto-generated if empty) |
| `existingConfigmap` | string | `""` | Name of existing ConfigMap with Keycloak configuration |
| `trustedCertsExistingSecret` | string | `""` | Name of existing Secret with trusted certificates |
| `adminRealm` | string | `"master"` | Name of the admin realm |
| `hostnameStrict` | boolean | `false` | Disables dynamically resolving hostname from request headers |
| `httpEnabled` | boolean | `false` | Force enabling HTTP endpoint |
| `extraStartupArgs` | string | `""` | Extra default startup args |
| `initdbScripts` | object | `{}` | Dictionary of initdb scripts to run at first boot |
| `initdbScriptsConfigMap` | string | `""` | ConfigMap with initdb scripts (overrides initdbScripts) |
| `command` | array | `[]` | Override default container command |
| `args` | array | `[]` | Override default container args |
| `extraEnvVars` | array | `[]` | Extra environment variables |
| `extraEnvVarsCM` | string | `""` | Name of existing ConfigMap containing extra env vars |
| `extraEnvVarsSecret` | string | `""` | Name of existing Secret containing extra env vars |

---

### TLS/SSL Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tls.enabled` | boolean | `false` | Enable TLS in Keycloak |
| `tls.usePemCerts` | boolean | `false` | Use PEM certificates instead of PKS12/JKS stores |
| `tls.autoGenerated.enabled` | boolean | `true` | Enable automatic TLS certificate generation |
| `tls.autoGenerated.engine` | string | `"helm"` | Certificate generation mechanism (helm or cert-manager) |
| `tls.autoGenerated.certManager.existingIssuer` | string | `""` | Name of existing Issuer (cert-manager only) |
| `tls.autoGenerated.certManager.existingIssuerKind` | string | `""` | Existing Issuer kind (cert-manager only) |
| `tls.autoGenerated.certManager.keySize` | number | `2048` | Key size for certificates (cert-manager only) |
| `tls.autoGenerated.certManager.keyAlgorithm` | string | `"RSA"` | Key algorithm for certificates (cert-manager only) |
| `tls.autoGenerated.certManager.duration` | string | `"2160h"` | Duration for certificates (cert-manager only) |
| `tls.autoGenerated.certManager.renewBefore` | string | `"360h"` | Renewal period for certificates (cert-manager only) |
| `tls.existingSecret` | string | `""` | Name of existing Secret with TLS certificates |
| `tls.certFilename` | string | `"tls.crt"` | Certificate filename in existing secret (PEM mode) |
| `tls.certKeyFilename` | string | `"tls.key"` | Certificate key filename in existing secret (PEM mode) |
| `tls.keystoreFilename` | string | `"keycloak.keystore.jks"` | Keystore filename in existing secret |
| `tls.truststoreFilename` | string | `"keycloak.truststore.jks"` | Truststore filename in existing secret |
| `tls.keystorePassword` | string | `""` | Password for keystore |
| `tls.truststorePassword` | string | `""` | Password for truststore |
| `tls.passwordsSecret` | string | `""` | Name of existing Secret with keystore/truststore passwords |

---

### Cache Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `cache.enabled` | boolean | `true` | Enable Keycloak distributed cache for Kubernetes |
| `cache.stack` | string | `"jdbc-ping"` | Cache stack to use |
| `cache.configFile` | string | `"cache-ispn.xml"` | Path to file for cache configuration |
| `cache.useHeadlessServiceWithAppVersion` | boolean | `false` | Create headless service with app version for ispn |
| `cache.javaOptsAppendExtra` | string | `""` | Extra java options to append |

---

### Logging Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `logging.output` | string | `"default"` | Log output format (default or json) |
| `logging.level` | string | `"INFO"` | Log level (FATAL, ERROR, WARN, INFO, DEBUG, TRACE, ALL, OFF) |

---

### Container Configuration Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `containerPorts.http` | number | `8080` | Keycloak HTTP container port |
| `containerPorts.https` | number | `8443` | Keycloak HTTPS container port |
| `containerPorts.management` | number | `9000` | Keycloak management container port |
| `extraContainerPorts` | array | `[]` | Extra list of additional ports for container |
| `extraVolumes` | array | `[]` | Extra list of additional volumes for pods |
| `extraVolumeMounts` | array | `[]` | Extra list of additional volumeMounts for container |
| `initContainers` | array | `[]` | Add additional init containers to pods |
| `sidecars` | array | `[]` | Add additional sidecar containers to pods |

---

### Security Context Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `podSecurityContext.enabled` | boolean | `true` | Enable pods' Security Context |
| `podSecurityContext.fsGroup` | number | `1001` | Pod Security Context fsGroup |
| `podSecurityContext.fsGroupChangePolicy` | string | `"Always"` | Filesystem group change policy |
| `podSecurityContext.sysctls` | array | `[]` | Set kernel settings using sysctl interface |
| `podSecurityContext.supplementalGroups` | array | `[]` | Set filesystem extra groups |
| `containerSecurityContext.enabled` | boolean | `true` | Enable containers' Security Context |
| `containerSecurityContext.runAsUser` | number | `1001` | Containers' Security Context runAsUser |
| `containerSecurityContext.runAsGroup` | number | `1001` | Containers' Security Context runAsGroup |
| `containerSecurityContext.runAsNonRoot` | boolean | `true` | Run containers as non-root |
| `containerSecurityContext.privileged` | boolean | `false` | Set container privileged |
| `containerSecurityContext.readOnlyRootFilesystem` | boolean | `true` | Set read-only root filesystem (auto-set for optimized images) |
| `containerSecurityContext.allowPrivilegeEscalation` | boolean | `false` | Allow privilege escalation |
| `containerSecurityContext.capabilities.drop` | array | `["ALL"]` | List of capabilities to drop |
| `containerSecurityContext.seccompProfile.type` | string | `"RuntimeDefault"` | Set seccomp profile type |
| `containerSecurityContext.seLinuxOptions` | object | `{}` | Set SELinux options in container |

---

### Resource Management Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `resourcesPreset` | string | `"small"` | Resource preset (none, nano, micro, small, medium, large, xlarge, 2xlarge) |
| `resources` | object | `{}` | Container resource requests and limits (overrides resourcesPreset) |

---

### Health Check Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `livenessProbe.enabled` | boolean | `true` | Enable livenessProbe |
| `livenessProbe.initialDelaySeconds` | number | `120` | Initial delay for livenessProbe |
| `livenessProbe.periodSeconds` | number | `1` | Period seconds for livenessProbe |
| `livenessProbe.timeoutSeconds` | number | `5` | Timeout seconds for livenessProbe |
| `livenessProbe.failureThreshold` | number | `3` | Failure threshold for livenessProbe |
| `livenessProbe.successThreshold` | number | `1` | Success threshold for livenessProbe |
| `readinessProbe.enabled` | boolean | `true` | Enable readinessProbe |
| `readinessProbe.initialDelaySeconds` | number | `30` | Initial delay for readinessProbe |
| `readinessProbe.periodSeconds` | number | `10` | Period seconds for readinessProbe |
| `readinessProbe.timeoutSeconds` | number | `1` | Timeout seconds for readinessProbe |
| `readinessProbe.failureThreshold` | number | `3` | Failure threshold for readinessProbe |
| `readinessProbe.successThreshold` | number | `1` | Success threshold for readinessProbe |
| `startupProbe.enabled` | boolean | `false` | Enable startupProbe |
| `startupProbe.initialDelaySeconds` | number | `30` | Initial delay for startupProbe |
| `startupProbe.periodSeconds` | number | `5` | Period seconds for startupProbe |
| `startupProbe.timeoutSeconds` | number | `1` | Timeout seconds for startupProbe |
| `startupProbe.failureThreshold` | number | `10` | Failure threshold for startupProbe |
| `startupProbe.successThreshold` | number | `1` | Success threshold for startupProbe |
| `customLivenessProbe` | object | `{}` | Custom Liveness probes |
| `customReadinessProbe` | object | `{}` | Custom Readiness probes |
| `customStartupProbe` | object | `{}` | Custom Startup probes |

---

### StatefulSet Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `replicaCount` | number | `1` | Number of Keycloak replicas to deploy |
| `updateStrategy.type` | string | `"RollingUpdate"` | StatefulSet update strategy type |
| `revisionHistoryLimitCount` | number | `10` | Number of controller revisions to keep |
| `minReadySeconds` | number | `0` | Seconds a pod needs to be ready before killing next during update |
| `statefulsetAnnotations` | object | `{}` | Extra annotations on StatefulSet resource |
| `automountServiceAccountToken` | boolean | `true` | Mount Service Account token in pods |
| `hostAliases` | array | `[]` | Pod host aliases |
| `podLabels` | object | `{}` | Extra labels for pods |
| `podAnnotations` | object | `{}` | Annotations for pods |
| `podManagementPolicy` | string | `"Parallel"` | Pod management policy for StatefulSet |
| `terminationGracePeriodSeconds` | string | `""` | Seconds pod needs to terminate gracefully |
| `lifecycleHooks` | object | `{}` | LifecycleHooks for additional configuration at startup |
| `dnsPolicy` | string | `""` | DNS Policy for pod |
| `dnsConfig` | object | `{}` | DNS Configuration for pod |
| `enableServiceLinks` | boolean | `true` | Enable Kubernetes service links in pod spec |

---

### Pod Scheduling Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `podAffinityPreset` | string | `""` | Pod affinity preset (soft or hard) |
| `podAntiAffinityPreset` | string | `"soft"` | Pod anti-affinity preset (soft or hard) |
| `nodeAffinityPreset.type` | string | `""` | Node affinity preset type (soft or hard) |
| `nodeAffinityPreset.key` | string | `""` | Node label key to match |
| `nodeAffinityPreset.values` | array | `[]` | Node label values to match |
| `affinity` | object | `{}` | Affinity for pod assignment |
| `nodeSelector` | object | `{}` | Node labels for pod assignment |
| `tolerations` | array | `[]` | Tolerations for pod assignment |
| `topologySpreadConstraints` | array | `[]` | Topology spread constraints for pod assignment |
| `priorityClassName` | string | `""` | Pods' Priority Class Name |
| `schedulerName` | string | `""` | Use alternate scheduler (e.g., "stork") |

---

### Service Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `service.type` | string | `"ClusterIP"` | Kubernetes service type |
| `service.http.enabled` | boolean | `true` | Enable HTTP port on service |
| `service.ports.http` | number | `80` | Keycloak HTTP service port |
| `service.ports.https` | number | `443` | Keycloak HTTPS service port |
| `service.nodePorts.http` | string | `""` | Node port for HTTP (30000-32767) |
| `service.nodePorts.https` | string | `""` | Node port for HTTPS (30000-32767) |
| `service.extraPorts` | array | `[]` | Extra ports to expose on service |
| `service.sessionAffinity` | string | `"None"` | Session affinity (ClientIP or None) |
| `service.sessionAffinityConfig` | object | `{}` | Additional settings for sessionAffinity |
| `service.clusterIP` | string | `""` | Service clusterIP IP |
| `service.loadBalancerIP` | string | `""` | LoadBalancer IP (cloud specific) |
| `service.loadBalancerSourceRanges` | array | `[]` | Addresses allowed when service is LoadBalancer |
| `service.externalTrafficPolicy` | string | `"Cluster"` | Enable client source IP preservation |
| `service.annotations` | object | `{}` | Additional annotations for service |
| `service.headless.annotations` | object | `{}` | Annotations for headless service |
| `service.headless.extraPorts` | array | `[]` | Extra ports to expose on headless service |

---

### Ingress Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ingress.enabled` | boolean | `false` | Enable ingress record generation |
| `ingress.pathType` | string | `"ImplementationSpecific"` | Ingress path type |
| `ingress.apiVersion` | string | `""` | Force Ingress API version (auto-detected if not set) |
| `ingress.hostname` | string | `"keycloak.local"` | Default hostname for ingress |
| `ingress.ingressClassName` | string | `""` | IngressClass to use |
| `ingress.controller` | string | `"default"` | Ingress controller type (default or gce) |
| `ingress.path` | string | `"{{ .Values.httpRelativePath }}"` | Default path for ingress record |
| `ingress.servicePort` | string | `"http"` | Backend service port to use |
| `ingress.annotations` | object | `{}` | Additional ingress annotations |
| `ingress.labels` | object | `{}` | Additional labels for Ingress resource |
| `ingress.tls` | boolean | `false` | Enable TLS for ingress hostname |
| `ingress.selfSigned` | boolean | `false` | Create self-signed TLS secret using Helm |
| `ingress.extraHosts` | array | `[]` | Additional hostname(s) for ingress |
| `ingress.extraPaths` | array | `[]` | Additional paths under main host |
| `ingress.extraTls` | array | `[]` | TLS configuration for additional hostnames |
| `ingress.secrets` | array | `[]` | Custom TLS certificates as secrets |
| `ingress.extraRules` | array | `[]` | Additional rules for ingress |

---

### Network Policy Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `networkPolicy.enabled` | boolean | `true` | Create NetworkPolicy |
| `networkPolicy.allowExternal` | boolean | `true` | Allow external connections (no label requirement) |
| `networkPolicy.allowExternalEgress` | boolean | `true` | Allow pod to access any range of port and destinations |
| `networkPolicy.addExternalClientAccess` | boolean | `true` | Allow access from pods with client label "true" |
| `networkPolicy.kubeAPIServerPorts` | array | `[443, 6443, 8443]` | List of possible kube-apiserver endpoints |
| `networkPolicy.extraIngress` | array | `[]` | Extra ingress rules to add |
| `networkPolicy.extraEgress` | array | `[]` | Extra egress rules to add |
| `networkPolicy.ingressPodMatchLabels` | object | `{}` | Labels to match for traffic from other pods |
| `networkPolicy.ingressNSMatchLabels` | object | `{}` | Labels to match for traffic from other namespaces |
| `networkPolicy.ingressNSPodMatchLabels` | object | `{}` | Pod labels to match for traffic from other namespaces |

---

### ServiceAccount Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `serviceAccount.create` | boolean | `true` | Create ServiceAccount |
| `serviceAccount.name` | string | `""` | ServiceAccount name (auto-generated if not set) |
| `serviceAccount.annotations` | object | `{}` | Additional Service Account annotations |
| `serviceAccount.automountServiceAccountToken` | boolean | `true` | Automount service account token |
| `serviceAccount.extraLabels` | object | `{}` | Additional Service Account labels |

---

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pdb.create` | boolean | `true` | Enable/disable Pod Disruption Budget |
| `pdb.minAvailable` | string | `""` | Minimum number/percentage of pods that should remain scheduled |
| `pdb.maxUnavailable` | string | `""` | Maximum number/percentage of pods that may be unavailable |

---

### Autoscaling Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `autoscaling.vpa.enabled` | boolean | `false` | Enable VPA for Keycloak pods |
| `autoscaling.vpa.annotations` | object | `{}` | Annotations for VPA resource |
| `autoscaling.vpa.controlledResources` | array | `[]` | Resources VPA can control (cpu, memory) |
| `autoscaling.vpa.maxAllowed` | object | `{}` | VPA max allowed resources for pod |
| `autoscaling.vpa.minAllowed` | object | `{}` | VPA min allowed resources for pod |
| `autoscaling.vpa.updatePolicy.updateMode` | string | `"Auto"` | Autoscaling update policy mode |
| `autoscaling.hpa.enabled` | boolean | `false` | Enable HPA for Keycloak pods |
| `autoscaling.hpa.minReplicas` | number | `1` | Minimum number of replicas |
| `autoscaling.hpa.maxReplicas` | number | `11` | Maximum number of replicas |
| `autoscaling.hpa.targetCPU` | string | `""` | Target CPU utilization percentage |
| `autoscaling.hpa.targetMemory` | string | `""` | Target Memory utilization percentage |
| `autoscaling.hpa.behavior.scaleUp.stabilizationWindowSeconds` | number | `120` | Stabilization window when scaling up |
| `autoscaling.hpa.behavior.scaleUp.selectPolicy` | string | `"Max"` | Policy priority when scaling up |
| `autoscaling.hpa.behavior.scaleUp.policies` | array | `[]` | HPA scaling policies when scaling up |
| `autoscaling.hpa.behavior.scaleDown.stabilizationWindowSeconds` | number | `300` | Stabilization window when scaling down |
| `autoscaling.hpa.behavior.scaleDown.selectPolicy` | string | `"Max"` | Policy priority when scaling down |
| `autoscaling.hpa.behavior.scaleDown.policies` | array | `[{type: Pods, value: 1, periodSeconds: 300}]` | HPA scaling policies when scaling down |

---

### Metrics Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `metrics.enabled` | boolean | `false` | Enable exposing Keycloak metrics |
| `metrics.service.ports.metrics` | number | `9000` | Metrics service port |
| `metrics.service.annotations` | object | `{prometheus.io/scrape: "true"}` | Annotations for metrics endpoints |
| `metrics.service.extraPorts` | array | `[]` | Additional ports for metrics service |
| `metrics.serviceMonitor.enabled` | boolean | `false` | Create Prometheus Operator ServiceMonitor |
| `metrics.serviceMonitor.namespace` | string | `""` | Namespace where Prometheus is running |
| `metrics.serviceMonitor.annotations` | object | `{}` | Additional annotations for ServiceMonitor |
| `metrics.serviceMonitor.labels` | object | `{}` | Extra labels for ServiceMonitor |
| `metrics.serviceMonitor.jobLabel` | string | `""` | Job name label for Prometheus |
| `metrics.serviceMonitor.honorLabels` | boolean | `false` | Choose metric's labels on collisions with target labels |
| `metrics.serviceMonitor.tlsConfig` | object | `{}` | TLS configuration for scrape endpoints |
| `metrics.serviceMonitor.interval` | string | `""` | Interval at which metrics should be scraped |
| `metrics.serviceMonitor.scrapeTimeout` | string | `""` | Timeout after which scrape is ended |
| `metrics.serviceMonitor.metricRelabelings` | array | `[]` | Additional relabeling of metrics |
| `metrics.serviceMonitor.relabelings` | array | `[]` | General relabeling |
| `metrics.serviceMonitor.selector` | object | `{}` | Prometheus instance selector labels |
| `metrics.prometheusRule.enabled` | boolean | `false` | Create PrometheusRule for alerting |
| `metrics.prometheusRule.namespace` | string | `""` | Namespace where Prometheus is running |
| `metrics.prometheusRule.labels` | object | `{}` | Additional labels for PrometheusRule |
| `metrics.prometheusRule.groups` | array | `[]` | Alert rule groups |

---

### Keycloak Config CLI Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `keycloakConfigCli.enabled` | boolean | `false` | Enable keycloak-config-cli job |
| `keycloakConfigCli.image.registry` | string | `"docker.io"` | Config CLI image registry |
| `keycloakConfigCli.image.repository` | string | `"bitnami/keycloak-config-cli"` | Config CLI image repository |
| `keycloakConfigCli.image.tag` | string | `"6.4.0-debian-12-r11"` | Config CLI image tag |
| `keycloakConfigCli.image.digest` | string | `""` | Config CLI image digest |
| `keycloakConfigCli.image.pullPolicy` | string | `"IfNotPresent"` | Config CLI image pull policy |
| `keycloakConfigCli.image.pullSecrets` | array | `[]` | Config CLI image pull secrets |
| `keycloakConfigCli.annotations` | object | `{}` | Annotations for job |
| `keycloakConfigCli.command` | array | `[]` | Command for running container |
| `keycloakConfigCli.args` | array | `[]` | Args for running container |
| `keycloakConfigCli.automountServiceAccountToken` | boolean | `true` | Mount Service Account token |
| `keycloakConfigCli.hostAliases` | array | `[]` | Job pod host aliases |
| `keycloakConfigCli.resourcesPreset` | string | `"small"` | Resource preset for config CLI |
| `keycloakConfigCli.resources` | object | `{}` | Container resource requests and limits |
| `keycloakConfigCli.containerSecurityContext.enabled` | boolean | `true` | Enable Security Context |
| `keycloakConfigCli.containerSecurityContext.runAsUser` | number | `1001` | runAsUser setting |
| `keycloakConfigCli.containerSecurityContext.runAsGroup` | number | `1001` | runAsGroup setting |
| `keycloakConfigCli.containerSecurityContext.runAsNonRoot` | boolean | `true` | Run as non-root |
| `keycloakConfigCli.containerSecurityContext.readOnlyRootFilesystem` | boolean | `true` | Read-only root filesystem |
| `keycloakConfigCli.podSecurityContext.enabled` | boolean | `true` | Enable pod Security Context |
| `keycloakConfigCli.podSecurityContext.fsGroup` | number | `1001` | Pod fsGroup |
| `keycloakConfigCli.backoffLimit` | number | `1` | Number of retries before marking Job failed |
| `keycloakConfigCli.podLabels` | object | `{}` | Pod extra labels |
| `keycloakConfigCli.podAnnotations` | object | `{}` | Pod annotations |
| `keycloakConfigCli.nodeSelector` | object | `{}` | Node labels for pod assignment |
| `keycloakConfigCli.tolerations` | array | `[]` | Tolerations for pod assignment |
| `keycloakConfigCli.availabilityCheck.enabled` | boolean | `true` | Wait until Keycloak is available |
| `keycloakConfigCli.availabilityCheck.timeout` | string | `""` | Timeout for availability check (default 120s) |
| `keycloakConfigCli.extraEnvVars` | array | `[]` | Additional environment variables |
| `keycloakConfigCli.extraEnvVarsCM` | string | `""` | ConfigMap with extra env vars |
| `keycloakConfigCli.extraEnvVarsSecret` | string | `""` | Secret with extra env vars |
| `keycloakConfigCli.extraVolumes` | array | `[]` | Extra volumes to add to job |
| `keycloakConfigCli.extraVolumeMounts` | array | `[]` | Extra volume mounts |
| `keycloakConfigCli.initContainers` | array | `[]` | Additional init containers |
| `keycloakConfigCli.sidecars` | array | `[]` | Additional sidecar containers |
| `keycloakConfigCli.configuration` | object | `{}` | Realms configuration (JSON/YAML) |
| `keycloakConfigCli.existingConfigmap` | string | `""` | Existing ConfigMap with configuration |
| `keycloakConfigCli.cleanupAfterFinished.enabled` | boolean | `false` | Enable cleanup for finished jobs |
| `keycloakConfigCli.cleanupAfterFinished.seconds` | number | `600` | TTL seconds after finished |

---

### Default Init Containers Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `defaultInitContainers.prepareWriteDirs.enabled` | boolean | `true` | Enable init container that copies writable directories |
| `defaultInitContainers.prepareWriteDirs.containerSecurityContext.enabled` | boolean | `true` | Enable Security Context |
| `defaultInitContainers.prepareWriteDirs.containerSecurityContext.runAsUser` | number | `1001` | runAsUser setting |
| `defaultInitContainers.prepareWriteDirs.containerSecurityContext.runAsGroup` | number | `1001` | runAsGroup setting |
| `defaultInitContainers.prepareWriteDirs.containerSecurityContext.runAsNonRoot` | boolean | `true` | Run as non-root |
| `defaultInitContainers.prepareWriteDirs.containerSecurityContext.readOnlyRootFilesystem` | boolean | `true` | Read-only root filesystem |
| `defaultInitContainers.prepareWriteDirs.resourcesPreset` | string | `"nano"` | Resource preset for init container |
| `defaultInitContainers.prepareWriteDirs.resources` | object | `{}` | Resource requests and limits |

---

### PostgreSQL Parameters (Subchart)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `postgresql.enabled` | boolean | `true` | Deploy PostgreSQL subchart |
| `postgresql.auth.postgresPassword` | string | `""` | PostgreSQL admin password |
| `postgresql.auth.username` | string | `"keycloak"` | PostgreSQL username |
| `postgresql.auth.password` | string | `""` | PostgreSQL user password |
| `postgresql.auth.database` | string | `"keycloak"` | PostgreSQL database name |
| `postgresql.auth.existingSecret` | string | `""` | Name of existing secret for PostgreSQL credentials |
| `postgresql.auth.secretKeys.userPasswordKey` | string | `"password"` | Key in existing secret for user password |
| `postgresql.architecture` | string | `"standalone"` | PostgreSQL architecture (standalone or replication) |
| `postgresql.primary.persistence.enabled` | boolean | `true` | Enable PostgreSQL persistence |
| `postgresql.primary.persistence.size` | string | `"8Gi"` | PostgreSQL PVC size |

---

### External Database Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `externalDatabase.host` | string | `""` | External database host (required if postgresql.enabled=false) |
| `externalDatabase.port` | number | `5432` | External database port |
| `externalDatabase.user` | string | `"keycloak"` | External database username |
| `externalDatabase.password` | string | `""` | External database password |
| `externalDatabase.database` | string | `"keycloak"` | External database name |
| `externalDatabase.schema` | string | `"public"` | External database schema |
| `externalDatabase.existingSecret` | string | `""` | Existing secret with database credentials |
| `externalDatabase.existingSecretUserKey` | string | `""` | Key in existing secret containing database user |
| `externalDatabase.existingSecretPasswordKey` | string | `""` | Key in existing secret containing database password |
| `externalDatabase.annotations` | object | `{}` | Additional annotations for external database secret |
| `externalDatabase.extraParams` | string | `""` | Additional JDBC connection parameters |

---

## Example Configurations

### High Availability Setup

```yaml
replicaCount: 3

cache:
  enabled: true
  stack: kubernetes

postgresql:
  architecture: replication
  readReplicas:
    replicaCount: 2

ingress:
  enabled: true
  hostname: keycloak.example.com
  tls: true
```

### External Database

```yaml
postgresql:
  enabled: false

externalDatabase:
  host: postgres.example.com
  port: 5432
  user: keycloak
  password: your-password
  database: keycloak
```

### Custom Resources

```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 2000m
    memory: 2Gi
```

## Security Considerations

- The chart runs as non-root user (UID 1001) by default
- `readOnlyRootFilesystem` is enabled for optimized images
- Network policies restrict traffic by default
- Secrets are mounted as files instead of environment variables

## Upgrading

### To 1.0.0

Initial release. No upgrade path required.

## Troubleshooting

### Pod fails to start with optimized image

Ensure you're not setting build-time environment variables like `KC_FEATURES` with optimized images. These images are pre-built.

### Database connection issues

Check that PostgreSQL is running and the credentials match:

```bash
kubectl get pods -l app.kubernetes.io/component=primary
kubectl logs <keycloak-pod> -c keycloak
```

## License

This chart is licensed under the Apache 2.0 License.

## Links

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [BySamio Images Repository](https://github.com/bysamio/images)
- [BySamio Charts Repository](https://github.com/bysamio/charts)
