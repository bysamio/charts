{{/*
Expand the name of the chart.
*/}}
{{- define "minio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "minio.fullname" -}}
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
{{- define "minio.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "minio.labels" -}}
helm.sh/chart: {{ include "minio.chart" . }}
{{ include "minio.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "minio.selectorLabels" -}}
app.kubernetes.io/name: {{ include "minio.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name
*/}}
{{- define "minio.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "minio.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Secret name for credentials
*/}}
{{- define "minio.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "minio.fullname" . }}
{{- end }}
{{- end }}

{{/*
Image name
*/}}
{{- define "minio.image" -}}
{{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository .Values.image.tag }}
{{- end }}

{{/*
MC Image name (for init buckets)
*/}}
{{- define "minio.mcImage" -}}
{{- printf "%s/%s:%s" .Values.initBuckets.image.registry .Values.initBuckets.image.repository .Values.initBuckets.image.tag }}
{{- end }}

{{/*
Headless service name (for StatefulSet)
*/}}
{{- define "minio.headlessServiceName" -}}
{{- printf "%s-headless" (include "minio.fullname" .) }}
{{- end }}

{{/*
Return the distributed server args.
Generates the URL pattern for distributed MinIO:
  http://<fullname>-{0..N-1}.<headless>.<namespace>.svc.cluster.local/data{0..D-1}
*/}}
{{- define "minio.distributedArgs" -}}
{{- $fullname := include "minio.fullname" . -}}
{{- $headless := include "minio.headlessServiceName" . -}}
{{- $replicas := int .Values.replicaCount -}}
{{- $drives := int .Values.drivesPerNode -}}
{{- if gt $drives 1 -}}
http://{{ $fullname }}-{0...{{ sub $replicas 1 }}}.{{ $headless }}.{{ .Release.Namespace }}.svc.cluster.local/data{0...{{ sub $drives 1 }}}
{{- else -}}
http://{{ $fullname }}-{0...{{ sub $replicas 1 }}}.{{ $headless }}.{{ .Release.Namespace }}.svc.cluster.local/data
{{- end -}}
{{- end }}
