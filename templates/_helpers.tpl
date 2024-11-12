{{/*
Expand the name of the chart.
*/}}
{{- define "ctfd.name" -}}
{{- default .Chart.Name .Values.ctfd.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ctfd.fullname" -}}
{{- if .Values.ctfd.fullnameOverride }}
{{- .Values.ctfd.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.ctfd.nameOverride }}
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
{{- define "ctfd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ctfd.labels" -}}
helm.sh/chart: {{ include "ctfd.chart" . }}
{{ include "ctfd.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ctfd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ctfd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ctfd.serviceAccountName" -}}
{{- if .Values.ctfd.serviceAccount.create }}
{{- default (include "ctfd.fullname" .) .Values.ctfd.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.ctfd.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
   Generate CTFd DATABASE_URL (internal bitnami mariadb-galera or external self managed mariadb-galera)
*/}}
{{- define "ctfd.DATABASE_URL" -}}
{{- if index .Values "mariadb-galera" "enabled" -}}
mysql+pymysql://{{ index .Values "mariadb-galera" "db" "user" | default "ctfd" }}:{{ index .Values "mariadb-galera" "db" "password" | default "ctfd" }}@{{ .Release.Name }}-mariadb-galera/{{ index .Values "mariadb-galera" "db" "name"| default "ctfd" }}
{{- else -}}
mysql+pymysql://{{ index .Values "mariadb-galera" "external" "username" }}:{{ index .Values "mariadb-galera" "external" "password" }}@{{ index .Values "mariadb-galera" "external" "host" }}/{{ index .Values "mariadb-galera" "external" "database" }}
{{- end -}}
{{- end -}}



{{/*
   Generate CTFd REDIS_URL (internal bitnami redis or external self managed redis)
*/}}
{{- define "ctfd.REDIS_URL" -}}
{{- if index .Values "redis-ha" "enabled" -}}
redis://{{ .Release.Name }}-redis-ha:6379
{{- else -}}
redis://{{ index .Values "redis-ha" "external" "username" }}:{{ index .Values "redis-ha" "external" "password" }}@{{ index .Values "redis-ha" "external" "host" }}:{{ index .Values "redis-ha" "external" "port" }}
{{- end -}}
{{- end -}}