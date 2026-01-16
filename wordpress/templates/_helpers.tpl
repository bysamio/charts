{{/*
Expand the name of the chart.
*/}}
{{- define "wordpress.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "wordpress.fullname" -}}
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
{{- define "wordpress.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wordpress.labels" -}}
helm.sh/chart: {{ include "wordpress.chart" . }}
{{ include "wordpress.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wordpress.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wordpress.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wordpress.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wordpress.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image
*/}}
{{- define "wordpress.image" -}}
{{- if .Values.image.digest }}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s@%s" .Values.global.imageRegistry .Values.image.repository .Values.image.digest }}
{{- else if .Values.image.registry }}
{{- printf "%s/%s@%s" .Values.image.registry .Values.image.repository .Values.image.digest }}
{{- else }}
{{- printf "%s@%s" .Values.image.repository .Values.image.digest }}
{{- end }}
{{- else }}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/%s:%s" .Values.global.imageRegistry .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- else if .Values.image.registry }}
{{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- else }}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Database host
*/}}
{{- define "wordpress.databaseHost" -}}
{{- if .Values.mariadb.enabled }}
{{- printf "%s-mariadb" .Release.Name }}
{{- else }}
{{- .Values.externalDatabase.host }}
{{- end }}
{{- end }}

{{/*
Database name
*/}}
{{- define "wordpress.databaseName" -}}
{{- if .Values.mariadb.enabled }}
{{- .Values.mariadb.auth.database }}
{{- else }}
{{- .Values.externalDatabase.database }}
{{- end }}
{{- end }}

{{/*
Database user
*/}}
{{- define "wordpress.databaseUser" -}}
{{- if .Values.mariadb.enabled }}
{{- .Values.mariadb.auth.username }}
{{- else }}
{{- .Values.externalDatabase.user }}
{{- end }}
{{- end }}

{{/*
Database password secret name
*/}}
{{- define "wordpress.databasePasswordSecret" -}}
{{- if .Values.mariadb.enabled }}
{{- printf "%s-mariadb" .Release.Name }}
{{- else if .Values.externalDatabase.existingSecret }}
{{- .Values.externalDatabase.existingSecret }}
{{- else }}
{{- printf "%s-db" (include "wordpress.fullname" .) }}
{{- end }}
{{- end }}

{{/*
WordPress secret name
*/}}
{{- define "wordpress.secretName" -}}
{{- if .Values.existingSecret }}
{{- .Values.existingSecret }}
{{- else }}
{{- printf "%s" (include "wordpress.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Memcached host
*/}}
{{- define "wordpress.memcachedHost" -}}
{{- if .Values.memcached.enabled }}
{{- printf "%s-memcached" .Release.Name }}
{{- else }}
{{- .Values.externalCache.host }}
{{- end }}
{{- end }}

{{/*
Memcached port
*/}}
{{- define "wordpress.memcachedPort" -}}
{{- if .Values.memcached.enabled }}
11211
{{- else }}
{{- .Values.externalCache.port }}
{{- end }}
{{- end }}

{{/*
Safely get Kubernetes version for compatibility checks
Handles cases where Capabilities.KubeVersion might be nil (e.g., when using --kube-version flag)
*/}}
{{- define "wordpress.kubeVersion" -}}
{{- if and .Capabilities .Capabilities.KubeVersion }}
{{- if .Capabilities.KubeVersion.GitVersion }}
{{- .Capabilities.KubeVersion.GitVersion }}
{{- else if .Capabilities.KubeVersion.Version }}
{{- printf "v%s" .Capabilities.KubeVersion.Version }}
{{- else }}
{{- "v1.19.0" -}}
{{- end }}
{{- else }}
{{- "v1.19.0" -}}
{{- end }}
{{- end }}
