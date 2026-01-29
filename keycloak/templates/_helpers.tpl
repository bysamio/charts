{{/*
Expand the name of the chart.
*/}}
{{- define "keycloak.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "keycloak.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
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
{{- define "keycloak.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Return the namespace to deploy to
*/}}
{{- define "keycloak.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "keycloak.labels" -}}
helm.sh/chart: {{ include "keycloak.chart" . }}
{{ include "keycloak.selectorLabels" . }}
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
{{- define "keycloak.selectorLabels" -}}
app.kubernetes.io/name: {{ include "keycloak.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: keycloak
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "keycloak.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "keycloak.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper Keycloak image name
*/}}
{{- define "keycloak.image" -}}
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
Return the proper keycloak-config-cli image name
*/}}
{{- define "keycloak.keycloakConfigCli.image" -}}
{{- $registryName := .Values.keycloakConfigCli.image.registry -}}
{{- $repositoryName := .Values.keycloakConfigCli.image.repository -}}
{{- $separator := ":" -}}
{{- $tag := .Values.keycloakConfigCli.image.tag | toString -}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- $registryName = .Values.global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if .Values.keycloakConfigCli.image.digest }}
    {{- $separator = "@" -}}
    {{- $tag = .Values.keycloakConfigCli.image.digest | toString -}}
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
{{- define "keycloak.imagePullSecrets" -}}
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
Return the Keycloak admin credentials secret name
*/}}
{{- define "keycloak.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- printf "%s" (include "keycloak.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the Keycloak admin password secret key
*/}}
{{- define "keycloak.secretPasswordKey" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.passwordSecretKey | default "admin-password" }}
{{- else }}
{{- "admin-password" }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL hostname
*/}}
{{- define "keycloak.databaseHost" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql-primary" .Release.Name }}
{{- else }}
{{- .Values.externalDatabase.host }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL port
*/}}
{{- define "keycloak.databasePort" -}}
{{- if .Values.postgresql.enabled }}
{{- 5432 }}
{{- else }}
{{- .Values.externalDatabase.port }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL database name
*/}}
{{- define "keycloak.databaseName" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database }}
{{- else }}
{{- .Values.externalDatabase.database }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL user
*/}}
{{- define "keycloak.databaseUser" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username }}
{{- else if .Values.externalDatabase.existingSecretUserKey }}
{{- "" }}
{{- else }}
{{- .Values.externalDatabase.user }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL secret name
*/}}
{{- define "keycloak.databaseSecretName" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" .Release.Name }}
{{- else if .Values.externalDatabase.existingSecret }}
{{- .Values.externalDatabase.existingSecret }}
{{- else }}
{{- printf "%s-db" (include "keycloak.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL password secret key
*/}}
{{- define "keycloak.databaseSecretPasswordKey" -}}
{{- if .Values.postgresql.enabled }}
{{- "password" }}
{{- else if .Values.externalDatabase.existingSecretPasswordKey }}
{{- .Values.externalDatabase.existingSecretPasswordKey }}
{{- else }}
{{- "db-password" }}
{{- end }}
{{- end }}

{{/*
Return the PostgreSQL user secret key (for external database)
*/}}
{{- define "keycloak.databaseSecretUserKey" -}}
{{- if .Values.externalDatabase.existingSecretUserKey }}
{{- .Values.externalDatabase.existingSecretUserKey }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Return the Keycloak configuration configmap name
*/}}
{{- define "keycloak.configmapName" -}}
{{- if .Values.existingConfigmap }}
{{- .Values.existingConfigmap }}
{{- else }}
{{- printf "%s-configuration" (include "keycloak.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the Keycloak initdb scripts configmap name
*/}}
{{- define "keycloak.initdbScriptsConfigmapName" -}}
{{- if .Values.initdbScriptsConfigMap }}
{{- .Values.initdbScriptsConfigMap }}
{{- else }}
{{- printf "%s-initdb-scripts" (include "keycloak.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the TLS secret name
*/}}
{{- define "keycloak.tlsSecretName" -}}
{{- if .Values.tls.existingSecret }}
{{- .Values.tls.existingSecret }}
{{- else }}
{{- printf "%s-tls" (include "keycloak.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the TLS passwords secret name
*/}}
{{- define "keycloak.tlsPasswordsSecretName" -}}
{{- if .Values.tls.passwordsSecret }}
{{- .Values.tls.passwordsSecret }}
{{- else }}
{{- printf "%s-tls-passwords" (include "keycloak.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return whether to create a TLS secret
*/}}
{{- define "keycloak.createTlsSecret" -}}
{{- if and .Values.tls.enabled .Values.tls.autoGenerated.enabled (not .Values.tls.existingSecret) }}
{{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the headless service name
*/}}
{{- define "keycloak.headlessServiceName" -}}
{{- if .Values.cache.useHeadlessServiceWithAppVersion }}
{{- printf "%s-headless-%s" (include "keycloak.fullname" .) (regexReplaceAll "[^a-zA-Z0-9-]" .Chart.AppVersion "-" | lower | trunc 10 | trimSuffix "-") }}
{{- else }}
{{- printf "%s-headless" (include "keycloak.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return the internal URL for Keycloak
*/}}
{{- define "keycloak.internalUrl" -}}
{{- $protocol := "http" -}}
{{- if .Values.tls.enabled -}}
{{- $protocol = "https" -}}
{{- end -}}
{{- $port := .Values.containerPorts.http -}}
{{- if .Values.tls.enabled -}}
{{- $port = .Values.containerPorts.https -}}
{{- end -}}
{{- printf "%s://%s:%d" $protocol (include "keycloak.fullname" .) (int $port) }}
{{- end }}

{{/*
Renders a value that contains template.
*/}}
{{- define "keycloak.tplvalues.render" -}}
{{- if typeIs "string" .value }}
{{- tpl .value .context }}
{{- else }}
{{- tpl (.value | toYaml) .context }}
{{- end }}
{{- end -}}

{{/*
Return pod affinity rules
*/}}
{{- define "keycloak.podAffinity" -}}
{{- if .Values.affinity }}
{{- toYaml .Values.affinity }}
{{- else }}
{{- if .Values.podAffinityPreset }}
podAffinity:
  {{- if eq .Values.podAffinityPreset "soft" }}
  preferredDuringSchedulingIgnoredDuringExecution:
    - podAffinityTerm:
        labelSelector:
          matchLabels:
            {{- include "keycloak.selectorLabels" . | nindent 12 }}
        topologyKey: kubernetes.io/hostname
      weight: 1
  {{- else if eq .Values.podAffinityPreset "hard" }}
  requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          {{- include "keycloak.selectorLabels" . | nindent 10 }}
      topologyKey: kubernetes.io/hostname
  {{- end }}
{{- end }}
{{- if .Values.podAntiAffinityPreset }}
podAntiAffinity:
  {{- if eq .Values.podAntiAffinityPreset "soft" }}
  preferredDuringSchedulingIgnoredDuringExecution:
    - podAffinityTerm:
        labelSelector:
          matchLabels:
            {{- include "keycloak.selectorLabels" . | nindent 12 }}
        topologyKey: kubernetes.io/hostname
      weight: 1
  {{- else if eq .Values.podAntiAffinityPreset "hard" }}
  requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          {{- include "keycloak.selectorLabels" . | nindent 10 }}
      topologyKey: kubernetes.io/hostname
  {{- end }}
{{- end }}
{{- if .Values.nodeAffinityPreset.type }}
nodeAffinity:
  {{- if eq .Values.nodeAffinityPreset.type "soft" }}
  preferredDuringSchedulingIgnoredDuringExecution:
    - preference:
        matchExpressions:
          - key: {{ .Values.nodeAffinityPreset.key }}
            operator: In
            values:
              {{- toYaml .Values.nodeAffinityPreset.values | nindent 14 }}
      weight: 1
  {{- else if eq .Values.nodeAffinityPreset.type "hard" }}
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
      - matchExpressions:
          - key: {{ .Values.nodeAffinityPreset.key }}
            operator: In
            values:
              {{- toYaml .Values.nodeAffinityPreset.values | nindent 14 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Return resource presets
*/}}
{{- define "keycloak.resourcePreset" -}}
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
Return the Keycloak resources
*/}}
{{- define "keycloak.resources" -}}
{{- if .Values.resources }}
{{- toYaml .Values.resources }}
{{- else if ne .Values.resourcesPreset "none" }}
{{- include "keycloak.resourcePreset" .Values.resourcesPreset }}
{{- end }}
{{- end }}

{{/*
Return the keycloak-config-cli resources
*/}}
{{- define "keycloak.keycloakConfigCli.resources" -}}
{{- if .Values.keycloakConfigCli.resources }}
{{- toYaml .Values.keycloakConfigCli.resources }}
{{- else if ne .Values.keycloakConfigCli.resourcesPreset "none" }}
{{- include "keycloak.resourcePreset" .Values.keycloakConfigCli.resourcesPreset }}
{{- end }}
{{- end }}

{{/*
Return the prepareWriteDirs init container resources
*/}}
{{- define "keycloak.prepareWriteDirs.resources" -}}
{{- if .Values.defaultInitContainers.prepareWriteDirs.resources }}
{{- toYaml .Values.defaultInitContainers.prepareWriteDirs.resources }}
{{- else if ne .Values.defaultInitContainers.prepareWriteDirs.resourcesPreset "none" }}
{{- include "keycloak.resourcePreset" .Values.defaultInitContainers.prepareWriteDirs.resourcesPreset }}
{{- end }}
{{- end }}

{{/*
Return pod security context
*/}}
{{- define "keycloak.podSecurityContext" -}}
{{- if .Values.podSecurityContext.enabled }}
{{- $context := omit .Values.podSecurityContext "enabled" }}
{{- if .Values.global }}
  {{- if eq (toString .Values.global.compatibility.openshift.adaptSecurityContext) "force" }}
    {{- $context = omit $context "fsGroup" "runAsUser" "runAsGroup" }}
  {{- end }}
{{- end }}
{{- toYaml $context }}
{{- end }}
{{- end }}

{{/*
Return whether the image is an optimized (pre-built) version
Checks if the image tag contains '-optimized'
*/}}
{{- define "keycloak.isOptimizedImage" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion | toString -}}
{{- if contains "-optimized" $tag -}}
{{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return container security context
Automatically adjusts readOnlyRootFilesystem based on image type:
- Optimized images (distroless): readOnlyRootFilesystem=true
- Flexible images (auto-build): readOnlyRootFilesystem=false (user must set manually)
*/}}
{{- define "keycloak.containerSecurityContext" -}}
{{- if .Values.containerSecurityContext.enabled }}
{{- $context := omit .Values.containerSecurityContext "enabled" }}
{{- if .Values.global }}
  {{- if eq (toString .Values.global.compatibility.openshift.adaptSecurityContext) "force" }}
    {{- $context = omit $context "runAsUser" "runAsGroup" }}
  {{- end }}
{{- end }}
{{- toYaml $context }}
{{- end }}
{{- end }}

{{/*
Return the keycloak-config-cli pod security context
*/}}
{{- define "keycloak.keycloakConfigCli.podSecurityContext" -}}
{{- if .Values.keycloakConfigCli.podSecurityContext.enabled }}
{{- $context := omit .Values.keycloakConfigCli.podSecurityContext "enabled" }}
{{- if .Values.global }}
  {{- if eq (toString .Values.global.compatibility.openshift.adaptSecurityContext) "force" }}
    {{- $context = omit $context "fsGroup" "runAsUser" "runAsGroup" }}
  {{- end }}
{{- end }}
{{- toYaml $context }}
{{- end }}
{{- end }}

{{/*
Return the keycloak-config-cli container security context
*/}}
{{- define "keycloak.keycloakConfigCli.containerSecurityContext" -}}
{{- if .Values.keycloakConfigCli.containerSecurityContext.enabled }}
{{- $context := omit .Values.keycloakConfigCli.containerSecurityContext "enabled" }}
{{- if .Values.global }}
  {{- if eq (toString .Values.global.compatibility.openshift.adaptSecurityContext) "force" }}
    {{- $context = omit $context "runAsUser" "runAsGroup" }}
  {{- end }}
{{- end }}
{{- toYaml $context }}
{{- end }}
{{- end }}

{{/*
Return the prepareWriteDirs container security context
*/}}
{{- define "keycloak.prepareWriteDirs.containerSecurityContext" -}}
{{- if .Values.defaultInitContainers.prepareWriteDirs.containerSecurityContext.enabled }}
{{- $context := omit .Values.defaultInitContainers.prepareWriteDirs.containerSecurityContext "enabled" }}
{{- if .Values.global }}
  {{- if eq (toString .Values.global.compatibility.openshift.adaptSecurityContext) "force" }}
    {{- $context = omit $context "runAsUser" "runAsGroup" }}
  {{- end }}
{{- end }}
{{- toYaml $context }}
{{- end }}
{{- end }}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "keycloak.validateValues" -}}
{{- $messages := list -}}
{{- $messages = append $messages (include "keycloak.validateValues.database" .) -}}
{{- $messages = append $messages (include "keycloak.validateValues.production" .) -}}
{{- $messages = without $messages "" -}}
{{- $message := join "\n" $messages -}}
{{- if $message -}}
{{- printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validate database configuration
*/}}
{{- define "keycloak.validateValues.database" -}}
{{- if and (not .Values.postgresql.enabled) (empty .Values.externalDatabase.host) -}}
keycloak: database
    You must provide an external database host when postgresql.enabled is false.
    Please set externalDatabase.host to a valid hostname.
{{- end -}}
{{- end -}}

{{/*
Validate production configuration
*/}}
{{- define "keycloak.validateValues.production" -}}
{{- if and .Values.production (not .Values.tls.enabled) (empty .Values.proxyHeaders) -}}
keycloak: production
    Running in production mode requires TLS or proxy headers configuration.
    Please enable TLS (tls.enabled=true) or set proxyHeaders.
{{- end -}}
{{- end -}}
