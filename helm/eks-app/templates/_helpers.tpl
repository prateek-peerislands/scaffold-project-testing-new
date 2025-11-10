{{/*
Expand the name of the chart.
*/}}
{{- define "eks-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If app.name is provided, use it; otherwise use chart name.
*/}}
{{- define "eks-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else if .Values.app.name }}
{{- .Values.app.name | trunc 63 | trimSuffix "-" }}
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
{{- define "eks-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "eks-app.labels" -}}
helm.sh/chart: {{ include "eks-app.chart" . }}
{{ include "eks-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.podLabels }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "eks-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eks-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "eks-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "eks-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Build health check probe based on configuration
*/}}
{{- define "eks-app.probe" -}}
{{- if .Values.healthCheck.httpGet.enabled }}
httpGet:
  path: {{ .Values.healthCheck.httpGet.path }}
  port: {{ .Values.healthCheck.httpGet.port }}
  scheme: {{ .Values.healthCheck.httpGet.scheme }}
{{- else if .Values.healthCheck.tcpSocket.enabled }}
tcpSocket:
  port: {{ .Values.healthCheck.tcpSocket.port }}
{{- else if .Values.healthCheck.exec.enabled }}
exec:
  command:
{{- range .Values.healthCheck.exec.command }}
    - {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}

