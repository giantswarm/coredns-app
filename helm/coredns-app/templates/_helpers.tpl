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

{{/*
Render the CoreDNS forward directive for the "." (public) zone. Call with nindent.

Forward-plugin parameters are taken from coredns.public.forward, a structured map
that mirrors the CoreDNS forward block parameters
(https://coredns.io/plugins/forward/). Only a representative subset of parameters is
wired up today; the design is deliberately extensible:
  - add a new structured key by appending one line to the option list below, plus a
    documented key in values.yaml and values.schema.json, or
  - set forward.raw for any parameter not yet exposed as a structured key.

Backward compatibility: when no structured parameters are set, the deprecated raw
configmap.forwardOptions string is used as a fallback.
*/}}
{{- define "coredns.forwardBlock" -}}
{{- $f := .Values.coredns.public.forward | default dict }}
{{- $upstreams := $f.to }}
{{- if $upstreams }}
{{- $lines := list }}
{{- with $f.policy }}{{ $lines = append $lines (printf "policy %v" .) }}{{ end }}
{{- if $f.forceTCP }}{{ $lines = append $lines "force_tcp" }}{{ end }}
{{- if $f.preferUDP }}{{ $lines = append $lines "prefer_udp" }}{{ end }}
{{- with $f.maxFails }}{{ $lines = append $lines (printf "max_fails %v" .) }}{{ end }}
{{- with $f.healthCheck }}{{ $lines = append $lines (printf "health_check %v" .) }}{{ end }}
{{- with $f.expire }}{{ $lines = append $lines (printf "expire %v" .) }}{{ end }}
{{- with $f.except }}{{ $lines = append $lines (printf "except %s" (join " " .)) }}{{ end }}
{{- with $f.raw }}{{ range (. | trimAll "\n " | splitList "\n") }}{{ $lines = append $lines . }}{{ end }}{{ end }}
{{- if and (not $lines) .Values.configmap.forwardOptions }}
{{- range (.Values.configmap.forwardOptions | trimAll "\n " | splitList "\n") }}{{ $lines = append $lines . }}{{ end }}
{{- end -}}
forward . {{ join " " $upstreams }}{{ if $lines }} {
{{- range $lines }}
  {{ . }}
{{- end }}
}{{ end }}
{{- else if .Values.configmap.forward }}
{{- $lines := list }}
{{- with .Values.configmap.forwardOptions }}{{ range (. | trimAll "\n " | splitList "\n") }}{{ $lines = append $lines . }}{{ end }}{{ end -}}
forward
{{- range (.Values.configmap.forward | trimAll "\n " | splitList "\n") }} {{ . }}{{- end }}{{ if $lines }} {
{{- range $lines }}
  {{ . }}
{{- end }}
}{{ end }}
{{- else -}}
forward . /etc/resolv.conf
{{- end }}
{{- end -}}

{{/*
Render a CoreDNS kubernetes directive. Call via include with a dict context:
  (dict "ctx" $ "zone" $domain "cidrs" "<serviceCIDR> <podCIDR>")
"cidrs" may be empty for zones without reverse (PTR) ranges.

Kubernetes-plugin parameters are taken from coredns.cluster.kubernetes, a structured
map that mirrors the CoreDNS kubernetes block parameters
(https://coredns.io/plugins/kubernetes/). Only a representative subset of parameters
is wired up today; the design is deliberately extensible:
  - add a new structured key by appending one line below, plus a documented key in
    values.yaml and values.schema.json, or
  - set kubernetes.raw for any parameter not yet exposed as a structured key.
*/}}
{{- define "coredns.kubernetesBlock" -}}
{{- $k := .ctx.Values.coredns.cluster.kubernetes | default dict -}}
kubernetes {{ .zone }}{{ with .cidrs }} {{ . }}{{ end }} {
  pods {{ $k.pods | default "verified" }}
  {{- with $k.ttl }}
  ttl {{ . }}
  {{- end }}
  {{- if $k.endpointPodNames }}
  endpoint_pod_names
  {{- end }}
  {{- if $k.noendpoints }}
  noendpoints
  {{- end }}
  {{- with $k.namespaces }}
  namespaces {{ join " " . }}
  {{- end }}
  {{- with $k.labels }}
  labels {{ . }}
  {{- end }}
  {{- if $k.ignoreEmptyService }}
  ignore empty_service
  {{- end }}
  {{- if $k.fallthrough }}
  fallthrough
  {{- end }}
  {{- with $k.raw }}
  {{- range (. | trimAll "\n " | splitList "\n") }}
  {{ . }}
  {{- end }}
  {{- end }}
}
{{- end -}}
