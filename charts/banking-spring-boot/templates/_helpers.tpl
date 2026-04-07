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

{{/*
Generate dependency env vars from values.dependencies.
*/}}
{{- define "banking-spring-boot.connectionEnv" -}}
{{- $d := .Values.dependencies -}}
{{- if $d.postgres.enabled }}
- name: POSTGRES_HOST
value: {{ $d.postgres.host | quote }}
- name: POSTGRES_PORT
value: {{ toString $d.postgres.port | quote }}
- name: POSTGRES_DB
value: {{ $d.postgres.database | quote }}
- name: POSTGRES_USER
value: {{ $d.postgres.username | quote }}
- name: POSTGRES_PASSWORD
valueFrom:
	secretKeyRef:
		name: {{ $d.postgres.passwordSecret.name | quote }}
		key: {{ $d.postgres.passwordSecret.key | quote }}
{{- end }}
{{- if $d.rabbitmq.enabled }}
- name: RABBITMQ_HOST
value: {{ $d.rabbitmq.host | quote }}
- name: RABBITMQ_PORT
value: {{ toString $d.rabbitmq.port | quote }}
- name: RABBITMQ_USER
value: {{ $d.rabbitmq.username | quote }}
- name: RABBITMQ_PASSWORD
valueFrom:
	secretKeyRef:
		name: {{ $d.rabbitmq.passwordSecret.name | quote }}
		key: {{ $d.rabbitmq.passwordSecret.key | quote }}
{{- end }}
{{- if $d.redis.enabled }}
- name: REDIS_HOST
value: {{ $d.redis.host | quote }}
- name: REDIS_PORT
value: {{ toString $d.redis.port | quote }}
- name: REDIS_DB
value: {{ toString $d.redis.database | quote }}
{{- if $d.redis.passwordSecret.name }}
- name: REDIS_PASSWORD
valueFrom:
	secretKeyRef:
		name: {{ $d.redis.passwordSecret.name | quote }}
		key: {{ $d.redis.passwordSecret.key | quote }}
{{- end }}
{{- end }}
{{- if $d.mongodb.enabled }}
- name: MONGODB_HOST
value: {{ $d.mongodb.host | quote }}
- name: MONGODB_PORT
value: {{ toString $d.mongodb.port | quote }}
- name: MONGODB_DB
value: {{ $d.mongodb.database | quote }}
- name: MONGODB_USER
value: {{ $d.mongodb.username | quote }}
- name: MONGODB_PASSWORD
valueFrom:
	secretKeyRef:
		name: {{ $d.mongodb.passwordSecret.name | quote }}
		key: {{ $d.mongodb.passwordSecret.key | quote }}
{{- end }}
{{- end }}
