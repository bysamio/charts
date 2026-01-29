{{/*
Expand the name of the chart.
*/}}
{{- define "postgresql.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "postgresql.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else if .Values.global.postgresql.fullnameOverride }}
{{- .Values.global.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "postgresql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Return the namespace to deploy to
*/}}
{{- define "postgresql.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "postgresql.labels" -}}
helm.sh/chart: {{ include "postgresql.chart" . }}
{{ include "postgresql.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "postgresql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgresql.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Primary selector labels
*/}}
{{- define "postgresql.primary.selectorLabels" -}}
{{ include "postgresql.selectorLabels" . }}
app.kubernetes.io/component: primary
{{- end }}

{{/*
Read replica selector labels
*/}}
{{- define "postgresql.readReplica.selectorLabels" -}}
{{ include "postgresql.selectorLabels" . }}
app.kubernetes.io/component: read
{{- end }}

{{/*
Return the proper PostgreSQL image name
*/}}
{{- define "postgresql.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $separator := ":" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion | toString -}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- $registryName = .Values.global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if .Values.image.digest }}
    {{- $separator = "@" -}}
    {{- $tag = .Values.image.digest | toString -}}
{{- end -}}
{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $tag -}}
{{- else -}}
    {{- printf "%s%s%s" $repositoryName $separator $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper metrics image name
*/}}
{{- define "postgresql.metrics.image" -}}
{{- $registryName := .Values.metrics.image.registry -}}
{{- $repositoryName := .Values.metrics.image.repository -}}
{{- $separator := ":" -}}
{{- $tag := .Values.metrics.image.tag | toString -}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- $registryName = .Values.global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if .Values.metrics.image.digest }}
    {{- $separator = "@" -}}
    {{- $tag = .Values.metrics.image.digest | toString -}}
{{- end -}}
{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $tag -}}
{{- else -}}
    {{- printf "%s%s%s" $repositoryName $separator $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper volume permissions image name
*/}}
{{- define "postgresql.volumePermissions.image" -}}
{{- $registryName := .Values.volumePermissions.image.registry -}}
{{- $repositoryName := .Values.volumePermissions.image.repository -}}
{{- $separator := ":" -}}
{{- $tag := .Values.volumePermissions.image.tag | toString -}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- $registryName = .Values.global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if .Values.volumePermissions.image.digest }}
    {{- $separator = "@" -}}
    {{- $tag = .Values.volumePermissions.image.digest | toString -}}
{{- end -}}
{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $tag -}}
{{- else -}}
    {{- printf "%s%s%s" $repositoryName $separator $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "postgresql.imagePullSecrets" -}}
{{- $pullSecrets := list }}
{{- if .Values.global }}
  {{- range .Values.global.imagePullSecrets -}}
    {{- $pullSecrets = append $pullSecrets . -}}
  {{- end -}}
{{- end -}}
{{- range .Values.image.pullSecrets -}}
  {{- $pullSecrets = append $pullSecrets . -}}
{{- end -}}
{{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
{{- range $pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "postgresql.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "postgresql.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL Secret Name
*/}}
{{- define "postgresql.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else if .Values.global.postgresql.auth.existingSecret }}
{{- .Values.global.postgresql.auth.existingSecret }}
{{- else }}
{{- include "postgresql.fullname" . }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL postgres password key
*/}}
{{- define "postgresql.adminPasswordKey" -}}
{{- if .Values.auth.existingSecret }}
{{- if .Values.auth.secretKeys.adminPasswordKey }}
{{- .Values.auth.secretKeys.adminPasswordKey }}
{{- else if .Values.global.postgresql.auth.secretKeys.adminPasswordKey }}
{{- .Values.global.postgresql.auth.secretKeys.adminPasswordKey }}
{{- else }}
{{- "postgres-password" }}
{{- end }}
{{- else }}
{{- "postgres-password" }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL user password key
*/}}
{{- define "postgresql.userPasswordKey" -}}
{{- if .Values.auth.existingSecret }}
{{- if .Values.auth.secretKeys.userPasswordKey }}
{{- .Values.auth.secretKeys.userPasswordKey }}
{{- else if .Values.global.postgresql.auth.secretKeys.userPasswordKey }}
{{- .Values.global.postgresql.auth.secretKeys.userPasswordKey }}
{{- else }}
{{- "password" }}
{{- end }}
{{- else }}
{{- "password" }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL replication password key
*/}}
{{- define "postgresql.replicationPasswordKey" -}}
{{- if .Values.auth.existingSecret }}
{{- if .Values.auth.secretKeys.replicationPasswordKey }}
{{- .Values.auth.secretKeys.replicationPasswordKey }}
{{- else if .Values.global.postgresql.auth.secretKeys.replicationPasswordKey }}
{{- .Values.global.postgresql.auth.secretKeys.replicationPasswordKey }}
{{- else }}
{{- "replication-password" }}
{{- end }}
{{- else }}
{{- "replication-password" }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL username
*/}}
{{- define "postgresql.username" -}}
{{- if .Values.global.postgresql.auth.username }}
{{- .Values.global.postgresql.auth.username }}
{{- else }}
{{- .Values.auth.username }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL database
*/}}
{{- define "postgresql.database" -}}
{{- if .Values.global.postgresql.auth.database }}
{{- .Values.global.postgresql.auth.database }}
{{- else }}
{{- .Values.auth.database }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL postgres password
*/}}
{{- define "postgresql.postgresPassword" -}}
{{- if .Values.global.postgresql.auth.postgresPassword }}
{{- .Values.global.postgresql.auth.postgresPassword }}
{{- else }}
{{- .Values.auth.postgresPassword }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL user password
*/}}
{{- define "postgresql.password" -}}
{{- if .Values.global.postgresql.auth.password }}
{{- .Values.global.postgresql.auth.password }}
{{- else }}
{{- .Values.auth.password }}
{{- end }}
{{- end }}

{{/*
Return PostgreSQL service port
*/}}
{{- define "postgresql.servicePort" -}}
{{- if .Values.global.postgresql.service.ports.postgresql }}
{{- .Values.global.postgresql.service.ports.postgresql }}
{{- else }}
{{- .Values.primary.service.ports.postgresql }}
{{- end }}
{{- end }}

{{/*
Return the primary fullname
*/}}
{{- define "postgresql.primary.fullname" -}}
{{- printf "%s-%s" (include "postgresql.fullname" .) .Values.primary.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Return the read replica fullname
*/}}
{{- define "postgresql.readReplica.fullname" -}}
{{- printf "%s-%s" (include "postgresql.fullname" .) .Values.readReplicas.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Return the configmap name for primary
*/}}
{{- define "postgresql.primary.configmapName" -}}
{{- if .Values.primary.existingConfigmap }}
{{- .Values.primary.existingConfigmap }}
{{- else }}
{{- printf "%s-configuration" (include "postgresql.primary.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the extended configmap name for primary
*/}}
{{- define "postgresql.primary.extendedConfigmapName" -}}
{{- if .Values.primary.existingExtendedConfigmap }}
{{- .Values.primary.existingExtendedConfigmap }}
{{- else }}
{{- printf "%s-extended-configuration" (include "postgresql.primary.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return whether to use password files
*/}}
{{- define "postgresql.usePasswordFile" -}}
{{- if .Values.auth.usePasswordFiles }}
{{- true -}}
{{- end -}}
{{- end -}}

{{/*
Renders a value that contains template.
*/}}
{{- define "postgresql.tplvalues.render" -}}
{{- if typeIs "string" .value }}
{{- tpl .value .context }}
{{- else }}
{{- tpl (.value | toYaml) .context }}
{{- end }}
{{- end -}}

{{/*
Return resource presets
*/}}
{{- define "postgresql.resourcePreset" -}}
{{- $preset := . -}}
{{- if eq $preset "nano" }}
requests:
  cpu: 100m
  memory: 128Mi
limits:
  cpu: 150m
  memory: 192Mi
{{- else if eq $preset "micro" }}
requests:
  cpu: 250m
  memory: 256Mi
limits:
  cpu: 500m
  memory: 512Mi
{{- else if eq $preset "small" }}
requests:
  cpu: 500m
  memory: 512Mi
limits:
  cpu: 1000m
  memory: 1Gi
{{- else if eq $preset "medium" }}
requests:
  cpu: 1000m
  memory: 1Gi
limits:
  cpu: 2000m
  memory: 2Gi
{{- else if eq $preset "large" }}
requests:
  cpu: 2000m
  memory: 2Gi
limits:
  cpu: 4000m
  memory: 4Gi
{{- else if eq $preset "xlarge" }}
requests:
  cpu: 4000m
  memory: 4Gi
limits:
  cpu: 8000m
  memory: 8Gi
{{- else if eq $preset "2xlarge" }}
requests:
  cpu: 8000m
  memory: 8Gi
limits:
  cpu: 16000m
  memory: 16Gi
{{- end }}
{{- end }}

{{/*
Return primary resources
*/}}
{{- define "postgresql.primary.resources" -}}
{{- if .Values.primary.resources }}
{{- toYaml .Values.primary.resources }}
{{- else if ne .Values.primary.resourcesPreset "none" }}
{{- include "postgresql.resourcePreset" .Values.primary.resourcesPreset }}
{{- end }}
{{- end }}

{{/*
Return read replica resources
*/}}
{{- define "postgresql.readReplica.resources" -}}
{{- if .Values.readReplicas.resources }}
{{- toYaml .Values.readReplicas.resources }}
{{- else if ne .Values.readReplicas.resourcesPreset "none" }}
{{- include "postgresql.resourcePreset" .Values.readReplicas.resourcesPreset }}
{{- end }}
{{- end }}

{{/*
Return metrics resources
*/}}
{{- define "postgresql.metrics.resources" -}}
{{- if .Values.metrics.resources }}
{{- toYaml .Values.metrics.resources }}
{{- else if ne .Values.metrics.resourcesPreset "none" }}
{{- include "postgresql.resourcePreset" .Values.metrics.resourcesPreset }}
{{- end }}
{{- end }}

{{/*
Return pod security context
*/}}
{{- define "postgresql.primary.podSecurityContext" -}}
{{- if .Values.primary.podSecurityContext.enabled }}
{{- $context := omit .Values.primary.podSecurityContext "enabled" }}
{{- if .Values.global }}
  {{- if eq (toString .Values.global.compatibility.openshift.adaptSecurityContext) "force" }}
    {{- $context = omit $context "fsGroup" "runAsUser" "runAsGroup" }}
  {{- end }}
{{- end }}
{{- toYaml $context }}
{{- end }}
{{- end }}

{{/*
Return container security context
*/}}
{{- define "postgresql.primary.containerSecurityContext" -}}
{{- if .Values.primary.containerSecurityContext.enabled }}
{{- $context := omit .Values.primary.containerSecurityContext "enabled" }}
{{- if .Values.global }}
  {{- if eq (toString .Values.global.compatibility.openshift.adaptSecurityContext) "force" }}
    {{- $context = omit $context "runAsUser" "runAsGroup" }}
  {{- end }}
{{- end }}
{{- toYaml $context }}
{{- end }}
{{- end }}

{{/*
Return read replica pod security context
*/}}
{{- define "postgresql.readReplica.podSecurityContext" -}}
{{- if .Values.readReplicas.podSecurityContext.enabled }}
{{- $context := omit .Values.readReplicas.podSecurityContext "enabled" }}
{{- if .Values.global }}
  {{- if eq (toString .Values.global.compatibility.openshift.adaptSecurityContext) "force" }}
    {{- $context = omit $context "fsGroup" "runAsUser" "runAsGroup" }}
  {{- end }}
{{- end }}
{{- toYaml $context }}
{{- end }}
{{- end }}

{{/*
Return read replica container security context
*/}}
{{- define "postgresql.readReplica.containerSecurityContext" -}}
{{- if .Values.readReplicas.containerSecurityContext.enabled }}
{{- $context := omit .Values.readReplicas.containerSecurityContext "enabled" }}
{{- if .Values.global }}
  {{- if eq (toString .Values.global.compatibility.openshift.adaptSecurityContext) "force" }}
    {{- $context = omit $context "runAsUser" "runAsGroup" }}
  {{- end }}
{{- end }}
{{- toYaml $context }}
{{- end }}
{{- end }}

{{/*
Return metrics container security context
*/}}
{{- define "postgresql.metrics.containerSecurityContext" -}}
{{- if .Values.metrics.containerSecurityContext.enabled }}
{{- $context := omit .Values.metrics.containerSecurityContext "enabled" }}
{{- if .Values.global }}
  {{- if eq (toString .Values.global.compatibility.openshift.adaptSecurityContext) "force" }}
    {{- $context = omit $context "runAsUser" "runAsGroup" }}
  {{- end }}
{{- end }}
{{- toYaml $context }}
{{- end }}
{{- end }}

{{/*
Return the TLS secret name
*/}}
{{- define "postgresql.tlsSecretName" -}}
{{- if .Values.tls.certificatesSecret }}
{{- .Values.tls.certificatesSecret }}
{{- else }}
{{- printf "%s-tls" (include "postgresql.fullname" .) }}
{{- end }}
{{- end }}
