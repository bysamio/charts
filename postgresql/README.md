# PostgreSQL Helm Chart

A Helm chart for deploying [PostgreSQL](https://www.postgresql.org/) using BySamio hardened Docker images.

## Overview

This chart deploys PostgreSQL, the world's most advanced open-source relational database, on Kubernetes. It uses BySamio's hardened container images that run as non-root (UID 1001) with security best practices.

## Features

- **Hardened Images**: Uses BySamio's security-hardened PostgreSQL images
- **Non-root Execution**: Runs as UID 1001 for enhanced security
- **Standalone & Replication**: Support for both standalone and primary-replica architectures
- **Metrics & Monitoring**: Prometheus exporter, ServiceMonitor, and PrometheusRule support
- **Security**: Network policies, PodDisruptionBudget, and comprehensive securityContext
- **Backup**: Built-in backup cronjob support
- **Password Files**: Mount credentials as files for enhanced security

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

### From OCI Registry

```bash
helm install postgresql oci://ghcr.io/bysamio/charts/postgresql \
  --namespace database \
  --create-namespace \
  --set auth.postgresPassword=your-admin-password \
  --set auth.password=your-user-password \
  --set auth.database=mydb \
  --set auth.username=myuser
```

### From Source

```bash
helm install postgresql ./postgresql \
  --namespace database \
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
| `global.storageClass` | string | `""` | DEPRECATED: use global.defaultStorageClass instead |
| `global.security.allowInsecureImages` | boolean | `false` | Allows skipping image verification |
| `global.postgresql.fullnameOverride` | string | `""` | Full chart name (overrides `fullnameOverride`) |
| `global.postgresql.auth.postgresPassword` | string | `""` | Password for postgres admin user (overrides `auth.postgresPassword`) |
| `global.postgresql.auth.username` | string | `""` | Custom user name (overrides `auth.username`) |
| `global.postgresql.auth.password` | string | `""` | Custom user password (overrides `auth.password`) |
| `global.postgresql.auth.database` | string | `""` | Custom database name (overrides `auth.database`) |
| `global.postgresql.auth.existingSecret` | string | `""` | Existing secret for credentials (overrides `auth.existingSecret`) |
| `global.postgresql.auth.secretKeys.adminPasswordKey` | string | `""` | Key for admin password in existing secret |
| `global.postgresql.auth.secretKeys.userPasswordKey` | string | `""` | Key for user password in existing secret |
| `global.postgresql.auth.secretKeys.replicationPasswordKey` | string | `""` | Key for replication password in existing secret |
| `global.postgresql.service.ports.postgresql` | string | `""` | PostgreSQL service port override |
| `global.compatibility.openshift.adaptSecurityContext` | string | `"auto"` | Adapt securityContext for Openshift (auto, force, disabled) |

---

### Common Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `kubeVersion` | string | `""` | Override Kubernetes version |
| `nameOverride` | string | `""` | String to partially override common.names.fullname |
| `fullnameOverride` | string | `""` | String to fully override common.names.fullname |
| `namespaceOverride` | string | `""` | String to fully override common.names.namespace |
| `clusterDomain` | string | `"cluster.local"` | Kubernetes cluster domain |
| `extraDeploy` | array | `[]` | Array of extra objects to deploy with the release |
| `commonLabels` | object | `{}` | Add labels to all deployed resources |
| `commonAnnotations` | object | `{}` | Add annotations to all deployed resources |
| `secretAnnotations` | object | `{}` | Add annotations to secrets |
| `diagnosticMode.enabled` | boolean | `false` | Enable diagnostic mode (all probes disabled) |
| `diagnosticMode.command` | array | `["sleep"]` | Command to override containers in diagnostic mode |
| `diagnosticMode.args` | array | `["infinity"]` | Args to override containers in diagnostic mode |

---

### Image Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `image.registry` | string | `"ghcr.io"` | PostgreSQL image registry |
| `image.repository` | string | `"bysamio/postgresql"` | PostgreSQL image repository |
| `image.tag` | string | `"17.7-alpine"` | PostgreSQL image tag (immutable tags recommended) |
| `image.digest` | string | `""` | PostgreSQL image digest (overrides tag if set) |
| `image.pullPolicy` | string | `"IfNotPresent"` | PostgreSQL image pull policy |
| `image.pullSecrets` | array | `[]` | PostgreSQL image pull secrets |
| `image.debug` | boolean | `false` | Enable debug mode |

---

### Authentication Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `auth.enablePostgresUser` | boolean | `true` | Assign password to "postgres" admin user |
| `auth.postgresPassword` | string | `""` | Password for postgres admin user (auto-generated if empty) |
| `auth.username` | string | `""` | Name for custom user to create |
| `auth.password` | string | `""` | Password for custom user (auto-generated if empty) |
| `auth.database` | string | `""` | Name for custom database to create |
| `auth.replicationUsername` | string | `"repl_user"` | Name of the replication user |
| `auth.replicationPassword` | string | `""` | Password for replication user |
| `auth.existingSecret` | string | `""` | Existing secret for PostgreSQL credentials |
| `auth.secretKeys.adminPasswordKey` | string | `"postgres-password"` | Key in existing secret for admin password |
| `auth.secretKeys.userPasswordKey` | string | `"password"` | Key in existing secret for user password |
| `auth.secretKeys.replicationPasswordKey` | string | `"replication-password"` | Key in existing secret for replication password |
| `auth.usePasswordFiles` | boolean | `true` | Mount credentials as files instead of env vars |

---

### PostgreSQL Configuration Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `architecture` | string | `"standalone"` | PostgreSQL architecture (standalone or replication) |
| `replication.synchronousCommit` | string | `"off"` | Synchronous commit mode (on, remote_apply, remote_write, local, off) |
| `replication.numSynchronousReplicas` | number | `0` | Number of replicas with synchronous replication |
| `replication.applicationName` | string | `"my_application"` | Cluster application name |
| `containerPorts.postgresql` | number | `5432` | PostgreSQL container port |
| `postgresqlDataDir` | string | `"/var/lib/postgresql/data"` | PostgreSQL data directory |
| `postgresqlSharedPreloadLibraries` | string | `"pgaudit"` | Shared preload libraries |

---

### Audit Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `audit.logHostname` | boolean | `false` | Log client hostnames |
| `audit.logConnections` | boolean | `false` | Add client log-in operations to log |
| `audit.logDisconnections` | boolean | `false` | Add client log-out operations to log |
| `audit.pgAuditLog` | string | `""` | Operations to log using pgAudit extension |
| `audit.pgAuditLogCatalog` | string | `"off"` | Log catalog using pgAudit |
| `audit.clientMinMessages` | string | `"error"` | Message log level to share with user |
| `audit.logLinePrefix` | string | `""` | Template for log line prefix |
| `audit.logTimezone` | string | `""` | Timezone for log timestamps |

---

### LDAP Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ldap.enabled` | boolean | `false` | Enable LDAP support |
| `ldap.server` | string | `""` | IP address or name of LDAP server |
| `ldap.port` | string | `""` | Port number on LDAP server |
| `ldap.prefix` | string | `""` | String to prepend to user name for DN |
| `ldap.suffix` | string | `""` | String to append to user name for DN |
| `ldap.basedn` | string | `""` | Root DN to begin user search |
| `ldap.binddn` | string | `""` | DN of user to bind to LDAP |
| `ldap.bindpw` | string | `""` | Password for user to bind to LDAP |
| `ldap.searchAttribute` | string | `""` | Attribute to match against user name |
| `ldap.searchFilter` | string | `""` | Search filter for search+bind authentication |
| `ldap.scheme` | string | `""` | Set to ldaps to use LDAPS |
| `ldap.tls.enabled` | boolean | `false` | Enable TLS encryption |
| `ldap.uri` | string | `""` | Complete LDAP URL (overrides other LDAP params) |

---

### SHM Volume Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `shmVolume.enabled` | boolean | `true` | Enable emptyDir volume for /dev/shm |
| `shmVolume.sizeLimit` | string | `""` | Size limit for shm tmpfs |

---

### TLS Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tls.enabled` | boolean | `false` | Enable TLS traffic support |
| `tls.autoGenerated` | boolean | `false` | Generate automatically self-signed TLS certificates |
| `tls.preferServerCiphers` | boolean | `true` | Use server's TLS cipher preferences |
| `tls.certificatesSecret` | string | `""` | Name of existing secret with certificates |
| `tls.certFilename` | string | `""` | Certificate filename |
| `tls.certKeyFilename` | string | `""` | Certificate key filename |
| `tls.certCAFilename` | string | `""` | CA Certificate filename |
| `tls.crlFilename` | string | `""` | Certificate Revocation List filename |

---

### PostgreSQL Primary Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `primary.name` | string | `"primary"` | Name of the primary database |
| `primary.configuration` | string | `""` | PostgreSQL main configuration to inject as ConfigMap |
| `primary.pgHbaConfiguration` | string | `""` | PostgreSQL client authentication configuration |
| `primary.existingConfigmap` | string | `""` | Existing ConfigMap with PostgreSQL configuration |
| `primary.extendedConfiguration` | string | `""` | Extended PostgreSQL configuration |
| `primary.existingExtendedConfigmap` | string | `""` | Existing ConfigMap with extended configuration |
| `primary.initdb.args` | string | `""` | PostgreSQL initdb extra arguments |
| `primary.initdb.postgresqlWalDir` | string | `""` | Custom location for transaction log |
| `primary.initdb.scripts` | object | `{}` | Dictionary of initdb scripts |
| `primary.initdb.scriptsConfigMap` | string | `""` | ConfigMap with initdb scripts |
| `primary.initdb.scriptsSecret` | string | `""` | Secret with initdb scripts |
| `primary.initdb.user` | string | `""` | PostgreSQL username to execute initdb scripts |
| `primary.initdb.password` | string | `""` | PostgreSQL password to execute initdb scripts |
| `primary.preInitDb.scripts` | object | `{}` | Dictionary of pre-init scripts |
| `primary.preInitDb.scriptsConfigMap` | string | `""` | ConfigMap with pre-init scripts |
| `primary.preInitDb.scriptsSecret` | string | `""` | Secret with pre-init scripts |
| `primary.standby.enabled` | boolean | `false` | Enable primary as standby of another cluster |
| `primary.standby.primaryHost` | string | `""` | Host of replication primary in other cluster |
| `primary.standby.primaryPort` | string | `""` | Port of replication primary in other cluster |
| `primary.extraEnvVars` | array | `[]` | Extra environment variables |
| `primary.extraEnvVarsCM` | string | `""` | ConfigMap with extra env vars |
| `primary.extraEnvVarsSecret` | string | `""` | Secret with extra env vars |
| `primary.command` | array | `[]` | Override default container command |
| `primary.args` | array | `[]` | Override default container args |

---

### Primary Health Check Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `primary.livenessProbe.enabled` | boolean | `true` | Enable livenessProbe |
| `primary.livenessProbe.initialDelaySeconds` | number | `30` | Initial delay for livenessProbe |
| `primary.livenessProbe.periodSeconds` | number | `10` | Period seconds for livenessProbe |
| `primary.livenessProbe.timeoutSeconds` | number | `5` | Timeout seconds for livenessProbe |
| `primary.livenessProbe.failureThreshold` | number | `6` | Failure threshold for livenessProbe |
| `primary.livenessProbe.successThreshold` | number | `1` | Success threshold for livenessProbe |
| `primary.readinessProbe.enabled` | boolean | `true` | Enable readinessProbe |
| `primary.readinessProbe.initialDelaySeconds` | number | `5` | Initial delay for readinessProbe |
| `primary.readinessProbe.periodSeconds` | number | `10` | Period seconds for readinessProbe |
| `primary.readinessProbe.timeoutSeconds` | number | `5` | Timeout seconds for readinessProbe |
| `primary.readinessProbe.failureThreshold` | number | `6` | Failure threshold for readinessProbe |
| `primary.readinessProbe.successThreshold` | number | `1` | Success threshold for readinessProbe |
| `primary.startupProbe.enabled` | boolean | `false` | Enable startupProbe |
| `primary.startupProbe.initialDelaySeconds` | number | `30` | Initial delay for startupProbe |
| `primary.startupProbe.periodSeconds` | number | `10` | Period seconds for startupProbe |
| `primary.startupProbe.timeoutSeconds` | number | `1` | Timeout seconds for startupProbe |
| `primary.startupProbe.failureThreshold` | number | `15` | Failure threshold for startupProbe |
| `primary.startupProbe.successThreshold` | number | `1` | Success threshold for startupProbe |
| `primary.customLivenessProbe` | object | `{}` | Custom livenessProbe |
| `primary.customReadinessProbe` | object | `{}` | Custom readinessProbe |
| `primary.customStartupProbe` | object | `{}` | Custom startupProbe |
| `primary.lifecycleHooks` | object | `{}` | Lifecycle hooks for container |

---

### Primary Resource Management Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `primary.resourcesPreset` | string | `"nano"` | Resource preset (none, nano, micro, small, medium, large, xlarge, 2xlarge) |
| `primary.resources` | object | `{}` | Container resource requests and limits (overrides resourcesPreset) |

---

### Primary Security Context Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `primary.podSecurityContext.enabled` | boolean | `true` | Enable security context |
| `primary.podSecurityContext.fsGroupChangePolicy` | string | `"Always"` | Filesystem group change policy |
| `primary.podSecurityContext.sysctls` | array | `[]` | Kernel settings using sysctl interface |
| `primary.podSecurityContext.supplementalGroups` | array | `[]` | Filesystem extra groups |
| `primary.podSecurityContext.fsGroup` | number | `1001` | Group ID for the pod |
| `primary.containerSecurityContext.enabled` | boolean | `true` | Enable container Security Context |
| `primary.containerSecurityContext.seLinuxOptions` | object | `{}` | SELinux options in container |
| `primary.containerSecurityContext.runAsUser` | number | `1001` | User ID for container |
| `primary.containerSecurityContext.runAsGroup` | number | `1001` | Group ID for container |
| `primary.containerSecurityContext.runAsNonRoot` | boolean | `true` | Run container as non-root |
| `primary.containerSecurityContext.privileged` | boolean | `false` | Set container privileged |
| `primary.containerSecurityContext.readOnlyRootFilesystem` | boolean | `true` | Set read-only root filesystem |
| `primary.containerSecurityContext.allowPrivilegeEscalation` | boolean | `false` | Allow privilege escalation |
| `primary.containerSecurityContext.capabilities.drop` | array | `["ALL"]` | List of capabilities to drop |
| `primary.containerSecurityContext.seccompProfile.type` | string | `"RuntimeDefault"` | Seccomp profile type |

---

### Primary Pod Configuration Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `primary.automountServiceAccountToken` | boolean | `false` | Mount Service Account token in pod |
| `primary.hostAliases` | array | `[]` | PostgreSQL primary pods host aliases |
| `primary.hostNetwork` | boolean | `false` | Enable host network for PostgreSQL pod |
| `primary.hostIPC` | boolean | `false` | Enable host IPC for PostgreSQL pod |
| `primary.labels` | object | `{}` | Map of labels to add to statefulset |
| `primary.annotations` | object | `{}` | Annotations for PostgreSQL primary pods |
| `primary.podLabels` | object | `{}` | Map of labels to add to pods |
| `primary.podAnnotations` | object | `{}` | Map of annotations to add to pods |

---

### Primary Pod Scheduling Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `primary.podAffinityPreset` | string | `""` | Pod affinity preset (soft or hard) |
| `primary.podAntiAffinityPreset` | string | `"soft"` | Pod anti-affinity preset (soft or hard) |
| `primary.nodeAffinityPreset.type` | string | `""` | Node affinity preset type (soft or hard) |
| `primary.nodeAffinityPreset.key` | string | `""` | Node label key to match |
| `primary.nodeAffinityPreset.values` | array | `[]` | Node label values to match |
| `primary.affinity` | object | `{}` | Affinity for pod assignment |
| `primary.nodeSelector` | object | `{}` | Node labels for pod assignment |
| `primary.tolerations` | array | `[]` | Tolerations for pod assignment |
| `primary.topologySpreadConstraints` | array | `[]` | Topology spread constraints for pod assignment |
| `primary.priorityClassName` | string | `""` | Priority Class for pods |
| `primary.schedulerName` | string | `""` | Use alternate scheduler (e.g., stork) |
| `primary.terminationGracePeriodSeconds` | string | `""` | Seconds pod needs to terminate gracefully |
| `primary.updateStrategy.type` | string | `"RollingUpdate"` | StatefulSet strategy type |
| `primary.updateStrategy.rollingUpdate` | object | `{}` | Rolling update configuration |

---

### Primary Volumes Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `primary.extraVolumeMounts` | array | `[]` | Extra list of additional volumeMounts |
| `primary.extraVolumes` | array | `[]` | Extra list of additional volumes |
| `primary.sidecars` | array | `[]` | Add additional sidecar containers |
| `primary.initContainers` | array | `[]` | Add additional init containers |

---

### Primary Pod Disruption Budget Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `primary.pdb.create` | boolean | `true` | Enable Pod Disruption Budget creation |
| `primary.pdb.minAvailable` | string | `""` | Minimum number/percentage of pods to remain scheduled |
| `primary.pdb.maxUnavailable` | string | `""` | Maximum number/percentage of pods that may be unavailable |

---

### Primary Network Policy Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `primary.networkPolicy.enabled` | boolean | `true` | Enable NetworkPolicy creation |
| `primary.networkPolicy.allowExternal` | boolean | `true` | Don't require server label for connections |
| `primary.networkPolicy.allowExternalEgress` | boolean | `true` | Allow pod to access any range of port |
| `primary.networkPolicy.extraIngress` | array | `[]` | Add extra ingress rules to NetworkPolicy |
| `primary.networkPolicy.extraEgress` | array | `[]` | Add extra egress rules to NetworkPolicy |
| `primary.networkPolicy.ingressNSMatchLabels` | object | `{}` | Labels to match for traffic from other namespaces |
| `primary.networkPolicy.ingressNSPodMatchLabels` | object | `{}` | Pod labels to match for traffic from other namespaces |

---

### Primary Service Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `primary.service.type` | string | `"ClusterIP"` | Kubernetes Service type |
| `primary.service.ports.postgresql` | number | `5432` | PostgreSQL service port |
| `primary.service.nodePorts.postgresql` | string | `""` | Node port for PostgreSQL |
| `primary.service.clusterIP` | string | `""` | Static clusterIP or None for headless services |
| `primary.service.labels` | object | `{}` | Map of labels to add to service |
| `primary.service.annotations` | object | `{}` | Annotations for PostgreSQL service |
| `primary.service.loadBalancerClass` | string | `""` | Load balancer class |
| `primary.service.loadBalancerIP` | string | `""` | Load balancer IP |
| `primary.service.externalTrafficPolicy` | string | `"Cluster"` | Enable client source IP preservation |
| `primary.service.loadBalancerSourceRanges` | array | `[]` | Allowed addresses when service is LoadBalancer |
| `primary.service.extraPorts` | array | `[]` | Extra ports to expose |
| `primary.service.sessionAffinity` | string | `"None"` | Session Affinity (None or ClientIP) |
| `primary.service.sessionAffinityConfig` | object | `{}` | Additional settings for sessionAffinity |
| `primary.service.headless.annotations` | object | `{}` | Annotations for headless service |

---

### Primary Persistence Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `primary.persistence.enabled` | boolean | `true` | Enable PostgreSQL data persistence using PVC |
| `primary.persistence.volumeName` | string | `"data"` | Name to assign the volume |
| `primary.persistence.existingClaim` | string | `""` | Name of existing PVC to use |
| `primary.persistence.mountPath` | string | `"/var/lib/postgresql"` | Path to mount the volume |
| `primary.persistence.subPath` | string | `""` | Subdirectory of volume to mount |
| `primary.persistence.storageClass` | string | `""` | PVC Storage Class |
| `primary.persistence.accessModes` | array | `["ReadWriteOnce"]` | PVC Access Mode |
| `primary.persistence.size` | string | `"8Gi"` | PVC Storage Request |
| `primary.persistence.annotations` | object | `{}` | Annotations for PVC |
| `primary.persistence.labels` | object | `{}` | Labels for PVC |
| `primary.persistence.selector` | object | `{}` | Selector to match existing Persistent Volume |
| `primary.persistence.dataSource` | object | `{}` | Custom PVC data source |
| `primary.persistentVolumeClaimRetentionPolicy.enabled` | boolean | `false` | Enable Persistent volume retention policy |
| `primary.persistentVolumeClaimRetentionPolicy.whenScaled` | string | `"Retain"` | Volume retention when replica count reduced |
| `primary.persistentVolumeClaimRetentionPolicy.whenDeleted` | string | `"Retain"` | Volume retention when StatefulSet deleted |
| `primary.extraPodSpec` | object | `{}` | Extra PodSpec for PostgreSQL pod |

---

### Read Replicas Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `readReplicas.name` | string | `"read"` | Name of read replicas database |
| `readReplicas.replicaCount` | number | `1` | Number of PostgreSQL read replicas |
| `readReplicas.extendedConfiguration` | string | `""` | Extended PostgreSQL read replicas configuration |
| `readReplicas.extraEnvVars` | array | `[]` | Extra environment variables |
| `readReplicas.extraEnvVarsCM` | string | `""` | ConfigMap with extra env vars |
| `readReplicas.extraEnvVarsSecret` | string | `""` | Secret with extra env vars |
| `readReplicas.command` | array | `[]` | Override default container command |
| `readReplicas.args` | array | `[]` | Override default container args |

**Note**: Read Replicas support the same health check, resource management, security context, pod configuration, scheduling, volumes, PDB, network policy, service, and persistence parameters as Primary. See Primary Parameters sections above and prefix with `readReplicas.` instead of `primary.`

---

### Backup Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `backup.enabled` | boolean | `false` | Enable logical dump of database regularly |
| `backup.cronjob.schedule` | string | `"@daily"` | Cronjob schedule |
| `backup.cronjob.timeZone` | string | `""` | Cronjob timeZone |
| `backup.cronjob.concurrencyPolicy` | string | `"Allow"` | Cronjob concurrencyPolicy |
| `backup.cronjob.failedJobsHistoryLimit` | number | `1` | Failed jobs history limit |
| `backup.cronjob.successfulJobsHistoryLimit` | number | `3` | Successful jobs history limit |
| `backup.cronjob.startingDeadlineSeconds` | string | `""` | Starting deadline seconds |
| `backup.cronjob.ttlSecondsAfterFinished` | string | `""` | TTL seconds after finished |
| `backup.cronjob.restartPolicy` | string | `"OnFailure"` | Restart policy |
| `backup.cronjob.podSecurityContext.enabled` | boolean | `true` | Enable PodSecurityContext for backup |
| `backup.cronjob.podSecurityContext.fsGroupChangePolicy` | string | `"Always"` | Filesystem group change policy |
| `backup.cronjob.podSecurityContext.sysctls` | array | `[]` | Kernel settings using sysctl |
| `backup.cronjob.podSecurityContext.supplementalGroups` | array | `[]` | Filesystem extra groups |
| `backup.cronjob.podSecurityContext.fsGroup` | number | `1001` | Group ID for cronjob |
| `backup.cronjob.containerSecurityContext.enabled` | boolean | `true` | Enable container Security Context |
| `backup.cronjob.containerSecurityContext.seLinuxOptions` | object | `{}` | SELinux options |
| `backup.cronjob.containerSecurityContext.runAsUser` | number | `1001` | Run as user |
| `backup.cronjob.containerSecurityContext.runAsGroup` | number | `1001` | Run as group |
| `backup.cronjob.containerSecurityContext.runAsNonRoot` | boolean | `true` | Run as non-root |
| `backup.cronjob.containerSecurityContext.privileged` | boolean | `false` | Set privileged |
| `backup.cronjob.containerSecurityContext.readOnlyRootFilesystem` | boolean | `true` | Read-only root filesystem |
| `backup.cronjob.containerSecurityContext.allowPrivilegeEscalation` | boolean | `false` | Allow privilege escalation |
| `backup.cronjob.containerSecurityContext.capabilities.drop` | array | `["ALL"]` | Capabilities to drop |
| `backup.cronjob.containerSecurityContext.seccompProfile.type` | string | `"RuntimeDefault"` | Seccomp profile type |
| `backup.cronjob.command` | array | `[/bin/bash, -c, ...]` | Command to run backup |
| `backup.cronjob.labels` | object | `{}` | Cronjob labels |
| `backup.cronjob.annotations` | object | `{}` | Cronjob annotations |
| `backup.cronjob.nodeSelector` | object | `{}` | Node labels for pod assignment |
| `backup.cronjob.tolerations` | array | `[]` | Tolerations for pod assignment |
| `backup.cronjob.resourcesPreset` | string | `"nano"` | Resource preset for backup |
| `backup.cronjob.resources` | object | `{}` | Resource requests and limits |
| `backup.cronjob.networkPolicy.enabled` | boolean | `true` | Enable NetworkPolicy for backup |
| `backup.cronjob.storage.enabled` | boolean | `true` | Enable PVC for backup data |
| `backup.cronjob.storage.existingClaim` | string | `""` | Existing PVC name |
| `backup.cronjob.storage.resourcePolicy` | string | `""` | Set to "keep" to avoid removing PVCs |
| `backup.cronjob.storage.storageClass` | string | `""` | PVC Storage Class |
| `backup.cronjob.storage.accessModes` | array | `["ReadWriteOnce"]` | PV Access Mode |
| `backup.cronjob.storage.size` | string | `"8Gi"` | PVC Storage Request |
| `backup.cronjob.storage.annotations` | object | `{}` | PVC annotations |
| `backup.cronjob.storage.mountPath` | string | `"/backup/pgdump"` | Path to mount volume |
| `backup.cronjob.storage.subPath` | string | `""` | Subdirectory of volume to mount |
| `backup.cronjob.storage.volumeClaimTemplates.selector` | object | `{}` | Label query for volume binding |
| `backup.cronjob.extraVolumeMounts` | array | `[]` | Extra volumeMounts for backup |
| `backup.cronjob.extraVolumes` | array | `[]` | Extra volumes for backup |

---

### Password Update Job Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `passwordUpdateJob.enabled` | boolean | `false` | Enable password update job |
| `passwordUpdateJob.backoffLimit` | number | `10` | Backoff limit of the job |
| `passwordUpdateJob.command` | array | `[]` | Override default container command |
| `passwordUpdateJob.args` | array | `[]` | Override default container args |
| `passwordUpdateJob.extraCommands` | string | `""` | Extra commands to pass to job |
| `passwordUpdateJob.previousPasswords.postgresPassword` | string | `""` | Previous postgres password |
| `passwordUpdateJob.previousPasswords.password` | string | `""` | Previous user password |
| `passwordUpdateJob.previousPasswords.replicationPassword` | string | `""` | Previous replication password |
| `passwordUpdateJob.previousPasswords.existingSecret` | string | `""` | Secret with previous passwords |
| `passwordUpdateJob.containerSecurityContext` | object | `{...}` | Container security context (same options as primary) |
| `passwordUpdateJob.podSecurityContext` | object | `{...}` | Pod security context (same options as primary) |
| `passwordUpdateJob.extraEnvVars` | array | `[]` | Extra environment variables |
| `passwordUpdateJob.extraEnvVarsCM` | string | `""` | ConfigMap with extra env vars |
| `passwordUpdateJob.extraEnvVarsSecret` | string | `""` | Secret with extra env vars |
| `passwordUpdateJob.extraVolumes` | array | `[]` | Extra volumes for job |
| `passwordUpdateJob.extraVolumeMounts` | array | `[]` | Extra volume mounts for job |
| `passwordUpdateJob.initContainers` | array | `[]` | Additional init containers |
| `passwordUpdateJob.resourcesPreset` | string | `"micro"` | Resource preset |
| `passwordUpdateJob.resources` | object | `{}` | Resource requests and limits |
| `passwordUpdateJob.customLivenessProbe` | object | `{}` | Custom livenessProbe |
| `passwordUpdateJob.customReadinessProbe` | object | `{}` | Custom readinessProbe |
| `passwordUpdateJob.customStartupProbe` | object | `{}` | Custom startupProbe |
| `passwordUpdateJob.automountServiceAccountToken` | boolean | `false` | Mount Service Account token |
| `passwordUpdateJob.hostAliases` | array | `[]` | Pod host aliases |
| `passwordUpdateJob.annotations` | object | `{}` | Job annotations |
| `passwordUpdateJob.podLabels` | object | `{}` | Additional pod labels |
| `passwordUpdateJob.podAnnotations` | object | `{}` | Additional pod annotations |

---

### Volume Permissions Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `volumePermissions.enabled` | boolean | `false` | Enable init container that changes volume permissions |
| `volumePermissions.image.registry` | string | `"docker.io"` | Init container image registry |
| `volumePermissions.image.repository` | string | `"bitnami/os-shell"` | Init container image repository |
| `volumePermissions.image.tag` | string | `"12-debian-12-r51"` | Init container image tag |
| `volumePermissions.image.digest` | string | `""` | Init container image digest |
| `volumePermissions.image.pullPolicy` | string | `"IfNotPresent"` | Init container pull policy |
| `volumePermissions.image.pullSecrets` | array | `[]` | Init container pull secrets |
| `volumePermissions.resourcesPreset` | string | `"nano"` | Resource preset for init container |
| `volumePermissions.resources` | object | `{}` | Resource requests and limits |
| `volumePermissions.containerSecurityContext.seLinuxOptions` | object | `{}` | SELinux options |
| `volumePermissions.containerSecurityContext.runAsUser` | number | `0` | User ID for init container |
| `volumePermissions.containerSecurityContext.runAsGroup` | number | `0` | Group ID for init container |
| `volumePermissions.containerSecurityContext.runAsNonRoot` | boolean | `false` | Run as non-root |
| `volumePermissions.containerSecurityContext.seccompProfile.type` | string | `"RuntimeDefault"` | Seccomp profile type |

---

### Other Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `serviceBindings.enabled` | boolean | `false` | Create secret for service binding (Experimental) |
| `serviceAccount.create` | boolean | `true` | Enable creation of ServiceAccount |
| `serviceAccount.name` | string | `""` | Name of ServiceAccount to use |
| `serviceAccount.automountServiceAccountToken` | boolean | `false` | Auto mount ServiceAccountToken |
| `serviceAccount.annotations` | object | `{}` | Additional annotations for ServiceAccount |
| `rbac.create` | boolean | `false` | Create Role and RoleBinding |
| `rbac.rules` | array | `[]` | Custom RBAC rules to set |
| `psp.create` | boolean | `false` | Create PodSecurityPolicy (deprecated) |

---

### Metrics Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `metrics.enabled` | boolean | `false` | Start a prometheus exporter |
| `metrics.image.registry` | string | `"docker.io"` | PostgreSQL Prometheus Exporter image registry |
| `metrics.image.repository` | string | `"bitnami/postgres-exporter"` | PostgreSQL Prometheus Exporter image repository |
| `metrics.image.tag` | string | `"0.17.1-debian-12-r16"` | PostgreSQL Prometheus Exporter image tag |
| `metrics.image.digest` | string | `""` | PostgreSQL Prometheus Exporter image digest |
| `metrics.image.pullPolicy` | string | `"IfNotPresent"` | Image pull policy |
| `metrics.image.pullSecrets` | array | `[]` | Image pull secrets |
| `metrics.collectors` | object | `{}` | Control enabled collectors |
| `metrics.customMetrics` | object | `{}` | Define additional custom metrics |
| `metrics.extraEnvVars` | array | `[]` | Extra environment variables |
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
| `metrics.livenessProbe.enabled` | boolean | `true` | Enable livenessProbe |
| `metrics.livenessProbe.initialDelaySeconds` | number | `5` | Initial delay |
| `metrics.livenessProbe.periodSeconds` | number | `10` | Period seconds |
| `metrics.livenessProbe.timeoutSeconds` | number | `5` | Timeout seconds |
| `metrics.livenessProbe.failureThreshold` | number | `6` | Failure threshold |
| `metrics.livenessProbe.successThreshold` | number | `1` | Success threshold |
| `metrics.readinessProbe.enabled` | boolean | `true` | Enable readinessProbe |
| `metrics.readinessProbe.initialDelaySeconds` | number | `5` | Initial delay |
| `metrics.readinessProbe.periodSeconds` | number | `10` | Period seconds |
| `metrics.readinessProbe.timeoutSeconds` | number | `5` | Timeout seconds |
| `metrics.readinessProbe.failureThreshold` | number | `6` | Failure threshold |
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
| `metrics.containerPorts.metrics` | number | `9187` | Metrics container port |
| `metrics.resourcesPreset` | string | `"nano"` | Resource preset |
| `metrics.resources` | object | `{}` | Resource requests and limits |
| `metrics.service.ports.metrics` | number | `9187` | Metrics service port |
| `metrics.service.clusterIP` | string | `""` | Static clusterIP |
| `metrics.service.sessionAffinity` | string | `"None"` | Session affinity |
| `metrics.service.annotations` | object | `{prometheus.io/scrape: "true"}` | Annotations for Prometheus auto-discovery |
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
| `metrics.prometheusRule.enabled` | boolean | `false` | Create PrometheusRule for Prometheus Operator |
| `metrics.prometheusRule.namespace` | string | `""` | Namespace for PrometheusRule |
| `metrics.prometheusRule.labels` | object | `{}` | Additional labels for PrometheusRule |
| `metrics.prometheusRule.rules` | array | `[]` | PrometheusRule definitions |


---

## Example Configurations

### Standalone Mode

Default deployment creates a single PostgreSQL instance:

```yaml
architecture: standalone

auth:
  postgresPassword: "secure-admin-password"
  username: "appuser"
  password: "secure-user-password"
  database: "appdb"

primary:
  persistence:
    enabled: true
    size: 10Gi
```

### Replication Mode

For high availability with read replicas:

```yaml
architecture: replication

auth:
  postgresPassword: "secure-admin-password"
  replicationPassword: "secure-replication-password"

readReplicas:
  replicaCount: 2
  persistence:
    enabled: true
    size: 10Gi
```

### Using an Existing Secret

```yaml
auth:
  existingSecret: my-postgresql-secret
  secretKeys:
    adminPasswordKey: postgres-password
    userPasswordKey: password
    replicationPasswordKey: replication-password
```

### Metrics and Monitoring

Enable Prometheus metrics exporter:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    namespace: monitoring
```

### Custom PostgreSQL Configuration

```yaml
primary:
  configuration: |-
    max_connections = 200
    shared_buffers = 256MB
    effective_cache_size = 768MB
    maintenance_work_mem = 128MB
    checkpoint_completion_target = 0.9
    wal_buffers = 8MB
    default_statistics_target = 100
    random_page_cost = 1.1
    effective_io_concurrency = 200

  pgHbaConfiguration: |-
    local all all trust
    host all all 127.0.0.1/32 md5
    host all all ::1/128 md5
    host all all 0.0.0.0/0 md5
```

### Backup Configuration

Enable automatic backups:

```yaml
backup:
  enabled: true
  cronjob:
    schedule: "@daily"
    storage:
      enabled: true
      size: 20Gi
```

## Security Considerations

- Runs as non-root user (UID 1001) by default
- `readOnlyRootFilesystem` is enabled
- Network policies restrict traffic by default
- Passwords mounted as files (not environment variables) when `auth.usePasswordFiles: true`
- PodDisruptionBudget ensures availability during updates

## Upgrading

### To 1.0.0

Initial release. No upgrade path required.

## Troubleshooting

### Connection refused

Check that the pod is running and ready:

```bash
kubectl get pods -l app.kubernetes.io/name=postgresql
kubectl logs <postgresql-pod>
```

### Permission denied on data directory

Ensure the PVC has correct permissions. You may need to enable volume permissions init container:

```yaml
volumePermissions:
  enabled: true
```

### Replication lag

Monitor replication status:

```sql
SELECT * FROM pg_stat_replication;
```

## License

This chart is licensed under the Apache 2.0 License.

## Links

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [BySamio Images Repository](https://github.com/bysamio/images)
- [BySamio Charts Repository](https://github.com/bysamio/charts)
