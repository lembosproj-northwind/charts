{{- define "ns.name" -}}
{{- if .Values.namespace.name -}}
{{- .Values.namespace.name -}}
{{- else -}}
{{- $env := .Values.lembos.environment | replace "/" "-" -}}
{{- if .Values.lembos.stamp -}}
{{- printf "%s-%s" $env .Values.lembos.stamp | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $env | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "ns.labels" -}}
app.kubernetes.io/managed-by: lembos
lembos.dev/environment: {{ .Values.lembos.environment | quote }}
lembos.dev/stage: {{ .Values.lembos.stage | quote }}
lembos.dev/stamp: {{ .Values.lembos.stamp | quote }}
{{- range $key, $value := .Values.lembos.dimensions }}
lembos.dev/dimension-{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end -}}
