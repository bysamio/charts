{{/*
Expand the name of the chart.
*/}}
{{- define "memcached.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "memcached.fullname" -}}
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
{{- define "memcached.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "memcached.labels" -}}
helm.sh/chart: {{ include "memcached.chart" . }}
{{ include "memcached.selectorLabels" . }}
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
{{- define "memcached.selectorLabels" -}}
app.kubernetes.io/name: {{ include "memcached.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "memcached.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "memcached.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper Memcached image name
*/}}
{{- define "memcached.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end }}

{{/*
Return the proper Metrics image name
*/}}
{{- define "memcached.metrics.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) }}
{{- end }}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "memcached.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.metrics.image) "global" .Values.global) }}
{{- end }}

{{/*
Return the Memcached Secret Name
*/}}
{{- define "memcached.secretName" -}}
{{- if .Values.auth.existingPasswordSecret }}
    {{- printf "%s" .Values.auth.existingPasswordSecret }}
{{- else }}
    {{- printf "%s" (include "memcached.fullname" .) }}
{{- end }}
{{- end }}

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
Return the proper Docker Image Registry Secret Names
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
Return pod affinity or anti-affinity rules based on the preset type
*/}}
{{- define "common.affinities.pods" -}}
{{- $type := default "" .type -}}
{{- if $type -}}
  {{- $customLabels := default (dict) .customLabels -}}
  {{- $labels := dict "app.kubernetes.io/name" (include "memcached.name" .context) "app.kubernetes.io/instance" .context.Release.Name -}}
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