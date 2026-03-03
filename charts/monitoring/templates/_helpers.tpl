{{/*
이미지 풀 네임: global.imageRegistry 또는 컴포넌트 image.registry + repository + tag
폐쇄망에서는 registry만 지정하면 됨.
*/}}
{{- define "monitoring.image" -}}
{{- $registry := default .root.Values.global.imageRegistry .component.image.registry -}}
{{- if $registry -}}{{- $registry -}}/{{- end -}}{{- .component.image.repository -}}:{{- .component.image.tag -}}
{{- end -}}

{{- define "monitoring.name" -}}{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}{{- end -}}
{{- define "monitoring.fullname" -}}{{- printf "%s-%s" .root.Release.Name .component | trunc 63 | trimSuffix "-" -}}{{- end -}}
{{- define "monitoring.labels" -}}
app.kubernetes.io/name: {{ include "monitoring.name" .root }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}
