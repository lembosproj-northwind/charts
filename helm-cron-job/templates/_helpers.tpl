{{- define "cronjob.name" -}}
{{- $c := .Values.lembos.component | default .Release.Name -}}
{{- $c | replace "/" "-" | trunc 52 | trimSuffix "-" -}}
{{- end -}}

{{/* Truncated harder than the other charts: a CronJob name becomes a Job name plus a timestamp
     suffix, and the generated name still has to fit inside 63 characters. */}}
{{- define "cronjob.fullname" -}}
{{- $n := include "cronjob.name" . -}}
{{- if .Values.lembos.stamp -}}
{{- printf "%s-%s" $n .Values.lembos.stamp | trunc 52 | trimSuffix "-" -}}
{{- else -}}{{- $n -}}{{- end -}}
{{- end -}}

{{- define "cronjob.image" -}}
{{- if .Values.image.digest -}}
{{- printf "%s@%s" .Values.image.repository .Values.image.digest -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default "latest") -}}
{{- end -}}
{{- end -}}

{{- define "cronjob.labels" -}}
app.kubernetes.io/name: {{ include "cronjob.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: lembos
lembos.dev/component: {{ .Values.lembos.component | quote }}
lembos.dev/environment: {{ .Values.lembos.environment | quote }}
lembos.dev/stamp: {{ .Values.lembos.stamp | quote }}
lembos.dev/spec-version: {{ .Values.lembos.specVersion | quote }}
{{- end -}}

{{- define "cronjob.resources" -}}
{{- $size := .Values.sizeClass | default "small" -}}
{{- toYaml (index .Values.sizes $size | default (index .Values.sizes "small")) -}}
{{- end -}}
