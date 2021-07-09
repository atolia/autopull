
{{/*
Common labels
*/}}
{{- define "common.labels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "common.vars" -}}

{{- range $key, $value := $.Values.vars }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}

{{- end -}}