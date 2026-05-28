{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "labels.common" -}}
{{ include "labels.selector" . }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/name: {{ .Values.name | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
giantswarm.io/service-type: "{{ .Values.serviceType }}"
helm.sh/chart: {{ include "chart" . | quote }}
kubernetes.io/cluster-service: "true"
kubernetes.io/name: "CoreDNS"
application.giantswarm.io/team: {{ index .Chart.Annotations "io.giantswarm.application.team" | quote }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "labels.selector" -}}
k8s-app: {{ .Values.name | quote }}
{{- end -}}

{{/*
Render the CoreDNS cache directive. Call with nindent to control indentation.
*/}}
{{- define "coredns.cacheBlock" -}}
{{- $c := .Values.coredns.cache }}
{{- $successCapacity := $c.success.capacity | default 9984 }}
{{- $successTTL := coalesce $c.success.ttl .Values.configmap.cache | default 30 }}
{{- $denialCapacity := $c.denial.capacity | default 9984 }}
{{- $denialTTL := $c.denial.ttl | default 5 -}}
cache{{- if $c.ttl }} {{ $c.ttl }}{{- end }} {
  success {{ $successCapacity }} {{ $successTTL }}{{- with $c.success.minTTL }} {{ . }}{{- end }}
  denial {{ $denialCapacity }} {{ $denialTTL }}{{- with $c.denial.minTTL }} {{ . }}{{- end }}
  {{- with $c.prefetch }}{{- if .amount }}
  prefetch {{ .amount }}{{- with .duration }} {{ . }}{{- end }}{{- with .percentage }} {{ . }}%{{- end }}
  {{- end }}{{- end }}
  {{- if and $c.serveStale $c.serveStale.enabled }}
  serve_stale{{- with $c.serveStale.duration }} {{ . }}{{- end }}{{- with $c.serveStale.refreshMode }} {{ . }}{{- end }}
  {{- end }}
  {{- with $c.servfail }}{{- with .duration }}
  servfail {{ . }}
  {{- end }}{{- end }}
  {{- if and $c.disable $c.disable.success }}
  disable success
  {{- end }}
  {{- if and $c.disable $c.disable.denial }}
  disable denial
  {{- end }}
  {{- if $c.keepttl }}
  keepttl
  {{- end }}
}
{{- end -}}
