{{/*
Expand the name of the chart.
*/}}
{{- define "wordpress.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
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
Return the proper WordPress image name
*/}}
{{- define "wordpress.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | toString -}}
{{- if .Values.global.imageRegistry }}
    {{- printf "%s/%s:%s" .Values.global.imageRegistry $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}
{{- end }}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "wordpress.imagePullSecrets" -}}
{{- if .Values.global.imagePullSecrets }}
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- else if .Values.image.pullSecrets }}
{{- range .Values.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified mariadb name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "wordpress.mariadb.fullname" -}}
{{- include "mariadb.primary.fullname" .Subcharts.mariadb -}}
{{- end }}

{{/*
Return the MariaDB Hostname
*/}}
{{- define "wordpress.databaseHost" -}}
{{- if .Values.mariadb.enabled }}
    {{- if eq .Values.mariadb.architecture "replication" }}
        {{- printf "%s-%s" (include "wordpress.mariadb.fullname" .) "primary" | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
        {{- printf "%s" (include "wordpress.mariadb.fullname" .) -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.host -}}
{{- end -}}
{{- end }}

{{/*
Return the MariaDB Port
*/}}
{{- define "wordpress.databasePort" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "3306" -}}
{{- else -}}
    {{- printf "%d" (.Values.externalDatabase.port | int ) -}}
{{- end -}}
{{- end }}

{{/*
Return the MariaDB Database Name
*/}}
{{- define "wordpress.databaseName" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "%s" .Values.mariadb.auth.database -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.database -}}
{{- end -}}
{{- end }}

{{/*
Return the MariaDB Username
*/}}
{{- define "wordpress.databaseUsername" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "%s" .Values.mariadb.auth.username -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.user -}}
{{- end -}}
{{- end }}

{{/*
Return the MariaDB Secret Name
*/}}
{{- define "wordpress.databaseSecretName" -}}
{{- if .Values.mariadb.enabled }}
    {{- if .Values.mariadb.auth.existingSecret }}
        {{- printf "%s" .Values.mariadb.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "wordpress.mariadb.fullname" .) -}}
    {{- end -}}
{{- else if .Values.externalDatabase.existingSecret }}
    {{- printf "%s" .Values.externalDatabase.existingSecret -}}
{{- else -}}
    {{- printf "%s-%s" (include "wordpress.fullname" .) "externaldb" -}}
{{- end -}}
{{- end }}

{{/*
Return the database password key
*/}}
{{- define "wordpress.databasePasswordKey" -}}
{{- if .Values.mariadb.enabled -}}
mariadb-password
{{- else -}}
mariadb-password
{{- end -}}
{{- end }}

{{/*
Return the WordPress Secret Name
*/}}
{{- define "wordpress.secretName" -}}
{{- if .Values.existingSecret }}
    {{- printf "%s" .Values.existingSecret -}}
{{- else -}}
    {{- printf "%s" (include "wordpress.fullname" .) -}}
{{- end -}}
{{- end }}

{{/*
Return the SMTP Secret Name
*/}}
{{- define "wordpress.smtpSecretName" -}}
{{- if .Values.smtpExistingSecret }}
    {{- printf "%s" .Values.smtpExistingSecret -}}
{{- else -}}
    {{- printf "%s" (include "wordpress.fullname" .) -}}
{{- end -}}
{{- end }}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "wordpress.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "wordpress.validateValues.database" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{- printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end }}

{{/* Validate values of WordPress - Database */}}
{{- define "wordpress.validateValues.database" -}}
{{- if and (not .Values.mariadb.enabled) (not .Values.externalDatabase.host) -}}
wordpress: database
    You disabled the MariaDB installation but you did not provide the required parameters
    to use an external database. To use an external database, please ensure you provide
    (at least) the following values:

        externalDatabase.host=DB_SERVER_HOST
        externalDatabase.database=DB_NAME
        externalDatabase.user=DB_USERNAME
        externalDatabase.password=DB_PASSWORD

    Alternatively, you can use an existing secret with the database credentials.
{{- end -}}
{{- end -}}

{{/*
Common template rendering function
Used to render values that may contain templates
*/}}
{{- define "common.tplvalues.render" -}}
{{- $value := typeIs "string" .value | ternary .value (.value | toYaml) }}
{{- if .context }}
{{- tpl $value .context }}
{{- else }}
{{- $value }}
{{- end }}
{{- end -}}

{{/*
Return the proper Storage Class
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
