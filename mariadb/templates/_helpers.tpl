{{/*
Expand the name of the chart.
*/}}
{{- define "mariadb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mariadb.fullname" -}}
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
{{- define "mariadb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mariadb.labels" -}}
helm.sh/chart: {{ include "mariadb.chart" . }}
{{ include "mariadb.selectorLabels" . }}
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
{{- define "mariadb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mariadb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Primary selector labels
*/}}
{{- define "mariadb.primary.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mariadb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: primary
{{- end }}

{{/*
Secondary selector labels
*/}}
{{- define "mariadb.secondary.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mariadb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: secondary
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mariadb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mariadb.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper MariaDB image name
*/}}
{{- define "mariadb.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end }}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "mariadb.volumePermissions.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end }}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "mariadb.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image) "global" .Values.global) }}
{{- end }}

{{/*
Return the MariaDB Hostname
*/}}
{{- define "mariadb.primary.fullname" -}}
{{- if eq .Values.architecture "replication" }}
    {{- printf "%s-%s" (include "mariadb.fullname" .) .Values.primary.name | trunc 63 | trimSuffix "-" }}
{{- else }}
    {{- include "mariadb.fullname" . }}
{{- end }}
{{- end }}

{{/*
Return the MariaDB Secondary Hostname
*/}}
{{- define "mariadb.secondary.fullname" -}}
{{- printf "%s-%s" (include "mariadb.fullname" .) .Values.secondary.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Return the MariaDB Secret Name
*/}}
{{- define "mariadb.secretName" -}}
{{- if .Values.auth.existingSecret }}
    {{- printf "%s" .Values.auth.existingSecret }}
{{- else }}
    {{- printf "%s" (include "mariadb.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Return whether Password should be mounted as file instead of environment variable
*/}}
{{- define "mariadb.usePasswordFile" -}}
{{- if or .Values.auth.usePasswordFiles .Values.auth.customPasswordFiles }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the user defined LoadBalancerIP for this release.
Note, returns 127.0.0.1 if using ClusterIP.
*/}}
{{- define "mariadb.serviceIP" -}}
{{- if eq .Values.primary.service.type "ClusterIP" -}}
127.0.0.1
{{- else -}}
{{- .Values.primary.service.loadBalancerIP | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Returns the proper service port
*/}}
{{- define "mariadb.servicePort" -}}
{{- .Values.primary.service.ports.mysql -}}
{{- end -}}

{{/*
Return the configmap with the MariaDB Primary configuration
*/}}
{{- define "mariadb.primary.configmapName" -}}
{{- if .Values.primary.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.primary.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s-configuration" (include "mariadb.primary.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the configmap with the MariaDB Secondary configuration
*/}}
{{- define "mariadb.secondary.configmapName" -}}
{{- if .Values.secondary.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.secondary.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s-configuration" (include "mariadb.secondary.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Determine if the primary headless service should be created.
Defaults to true when using replication architecture, otherwise false
unless the user explicitly sets primary.service.headless.enabled.
*/}}
{{- define "mariadb.primary.headlessEnabled" -}}
{{- $headlessValues := default (dict) .Values.primary.service.headless -}}
{{- $enabled := eq .Values.architecture "replication" -}}
{{- if hasKey $headlessValues "enabled" -}}
  {{- $explicit := index $headlessValues "enabled" -}}
  {{- if kindIs "bool" $explicit -}}
    {{- $enabled = $explicit -}}
  {{- end -}}
{{- end -}}
{{- $enabled -}}
{{- end -}}

{{/*
Return the namespace to deploy to
*/}}
{{- define "common.names.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Render image reference
*/}}
{{- define "common.images.image" -}}
{{- $registryName := .imageRoot.registry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $separator := ":" -}}
{{- $tag := .imageRoot.tag | toString -}}
{{- if .global }}
    {{- if .global.imageRegistry }}
        {{- $registryName = .global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if .imageRoot.digest }}
    {{- $separator = "@" -}}
    {{- $tag = .imageRoot.digest | toString -}}
{{- end -}}
{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $tag -}}
{{- else -}}
    {{- printf "%s%s%s" $repositoryName $separator $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names (deprecated: use common.images.renderPullSecrets instead)
*/}}
{{- define "common.images.pullSecrets" -}}
{{- $pullSecrets := list }}
{{- if .global }}
  {{- range .global.imagePullSecrets -}}
    {{- $pullSecrets = append $pullSecrets . -}}
  {{- end -}}
{{- end -}}
{{- range .images -}}
  {{- range .pullSecrets -}}
    {{- $pullSecrets = append $pullSecrets . -}}
  {{- end -}}
{{- end -}}
{{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
{{- range $pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Renders a value that contains template.
*/}}
{{- define "common.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "common.capabilities.deployment.apiVersion" -}}
{{- if semverCompare ">=1.9-0" .Capabilities.KubeVersion.Version -}}
{{- print "apps/v1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return  the proper Storage Class
*/}}
{{- define "common.storage.class" -}}
{{- $storageClass := .persistence.storageClass -}}
{{- if .global -}}
    {{- if .global.storageClass -}}
        {{- $storageClass = .global.storageClass -}}
    {{- end -}}
{{- end -}}
{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return pod affinity or pod anti-affinity rules based on the preset type
*/}}
{{- define "common.affinities.pods" -}}
{{- $type := default "" .type -}}
{{- if $type -}}
  {{- $component := default "" .component -}}
  {{- $customLabels := default (dict) .customLabels -}}
  {{- $labels := dict "app.kubernetes.io/name" (include "mariadb.name" .context) "app.kubernetes.io/instance" .context.Release.Name -}}
  {{- if $component }}
    {{- $_ := set $labels "app.kubernetes.io/component" $component -}}
  {{- end -}}
  {{- range $key, $value := $customLabels }}
    {{- if ne (printf "%v" $value) "" }}
      {{- $_ := set $labels $key (printf "%v" $value) -}}
    {{- end -}}
  {{- end -}}
  {{- $topologyKey := default "kubernetes.io/hostname" .topologyKey -}}
  {{- if eq $type "soft" }}
preferredDuringSchedulingIgnoredDuringExecution:
  - podAffinityTerm:
      labelSelector:
        matchLabels:
{{- $labels | toYaml | nindent 10 }}
      topologyKey: {{ $topologyKey }}
    weight: {{ default 1 .weight }}
  {{- else if eq $type "hard" }}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels:
{{- $labels | toYaml | nindent 8 }}
    topologyKey: {{ $topologyKey }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return node affinity rules based on the preset type
*/}}
{{- define "common.affinities.nodes" -}}
{{- $type := default "" .type -}}
{{- $key := default "" .key -}}
{{- $values := default (list) .values -}}
{{- if and $type $key (gt (len $values) 0) -}}
  {{- if eq $type "soft" }}
preferredDuringSchedulingIgnoredDuringExecution:
  - preference:
      matchExpressions:
        - key: {{ $key }}
          operator: In
          values:
{{- $values | toYaml | nindent 12 }}
    weight: {{ default 1 .weight }}
  {{- else if eq $type "hard" }}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
    - matchExpressions:
        - key: {{ $key }}
          operator: In
          values:
{{- $values | toYaml | nindent 12 }}
  {{- end -}}
{{- end -}}
{{- end -}}
