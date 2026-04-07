{{/*
Expand the name of the chart.
*/}}
{{- define "banking-spring-boot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "banking-spring-boot.fullname" -}}
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
{{- define "banking-spring-boot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "banking-spring-boot.labels" -}}
helm.sh/chart: {{ include "banking-spring-boot.chart" . }}
{{ include "banking-spring-boot.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "banking-spring-boot.selectorLabels" -}}
app.kubernetes.io/name: {{ include "banking-spring-boot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "banking-spring-boot.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "banking-spring-boot.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Validate required connection settings when a dependency is enabled.
*/}}
{{- define "banking-spring-boot.validateDependencyConfig" -}}
{{- $d := .Values.dependencies -}}
{{- if $d.postgres.enabled }}
{{- if not $d.postgres.host }}{{ fail "dependencies.postgres.host is required when dependencies.postgres.enabled=true" }}{{ end }}
{{- if not $d.postgres.database }}{{ fail "dependencies.postgres.database is required when dependencies.postgres.enabled=true" }}{{ end }}
{{- if not $d.postgres.username }}{{ fail "dependencies.postgres.username is required when dependencies.postgres.enabled=true" }}{{ end }}
{{- if not $d.postgres.passwordSecret.name }}{{ fail "dependencies.postgres.passwordSecret.name is required when dependencies.postgres.enabled=true" }}{{ end }}
{{- if not $d.postgres.passwordSecret.key }}{{ fail "dependencies.postgres.passwordSecret.key is required when dependencies.postgres.enabled=true" }}{{ end }}
{{- end }}
{{- if $d.rabbitmq.enabled }}
{{- if not $d.rabbitmq.host }}{{ fail "dependencies.rabbitmq.host is required when dependencies.rabbitmq.enabled=true" }}{{ end }}
{{- if not $d.rabbitmq.username }}{{ fail "dependencies.rabbitmq.username is required when dependencies.rabbitmq.enabled=true" }}{{ end }}
{{- if not $d.rabbitmq.passwordSecret.name }}{{ fail "dependencies.rabbitmq.passwordSecret.name is required when dependencies.rabbitmq.enabled=true" }}{{ end }}
{{- if not $d.rabbitmq.passwordSecret.key }}{{ fail "dependencies.rabbitmq.passwordSecret.key is required when dependencies.rabbitmq.enabled=true" }}{{ end }}
{{- end }}
{{- if $d.redis.enabled }}
{{- if not $d.redis.host }}{{ fail "dependencies.redis.host is required when dependencies.redis.enabled=true" }}{{ end }}
{{- end }}
{{- if $d.mongodb.enabled }}
{{- if not $d.mongodb.host }}{{ fail "dependencies.mongodb.host is required when dependencies.mongodb.enabled=true" }}{{ end }}
{{- if not $d.mongodb.database }}{{ fail "dependencies.mongodb.database is required when dependencies.mongodb.enabled=true" }}{{ end }}
{{- if not $d.mongodb.username }}{{ fail "dependencies.mongodb.username is required when dependencies.mongodb.enabled=true" }}{{ end }}
{{- if not $d.mongodb.passwordSecret.name }}{{ fail "dependencies.mongodb.passwordSecret.name is required when dependencies.mongodb.enabled=true" }}{{ end }}
{{- if not $d.mongodb.passwordSecret.key }}{{ fail "dependencies.mongodb.passwordSecret.key is required when dependencies.mongodb.enabled=true" }}{{ end }}
{{- end }}
{{- end }}

{{/*
Validate service configuration used by templates.
*/}}
{{- define "banking-spring-boot.validateServiceConfig" -}}
{{- if not .Values.service.port }}{{ fail "service.port is required" }}{{ end }}
{{- if and (eq (toString .Values.service.targetPort) "http") (not .Values.container.portName) }}
{{- fail "container.portName is required when service.targetPort is 'http'" }}
{{- end }}
{{- end }}

