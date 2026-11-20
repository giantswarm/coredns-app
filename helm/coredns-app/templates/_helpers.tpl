{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimAll "-._" -}}
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
Render the CoreDNS cache directive. Call via include with a dict context:
  (dict "zone" $zone)
The zone's cache config is read from $zone.cache (may be absent — built-in defaults
then apply). Renders nothing when cache.enabled is false.
*/}}
{{- define "coredns.cacheBlock" -}}
{{- $c := .zone.cache | default dict }}
{{- if dig "enabled" true $c }}
{{- $success := $c.success | default dict }}
{{- $denial := $c.denial | default dict }}
{{- $successCapacity := $success.capacity | default 9984 }}
{{- $successTTL := $success.ttl | default 30 }}
{{- $denialCapacity := $denial.capacity | default 9984 }}
{{- $denialTTL := $denial.ttl | default 5 -}}
cache{{- if $c.ttl }} {{ $c.ttl }}{{- end }}{{- with $c.zones }} {{ join " " . }}{{- end }} {
  success {{ $successCapacity }} {{ $successTTL }}{{- with $success.minTTL }} {{ . }}{{- end }}
  denial {{ $denialCapacity }} {{ $denialTTL }}{{- with $denial.minTTL }} {{ . }}{{- end }}
  {{- with $c.prefetch }}{{- if .amount }}
  prefetch {{ .amount }}{{- with .duration }} {{ . }}{{- end }}{{- with .percentage }} {{ . }}%{{- end }}
  {{- end }}{{- end }}
  {{- if and $c.serveStale $c.serveStale.enabled }}
  serve_stale{{- with $c.serveStale.duration }} {{ . }}{{- end }}{{- with $c.serveStale.refreshMode }} {{ . }}{{- with $c.serveStale.verifyTimeout }} {{ . }}{{- end }}{{- end }}
  {{- end }}
  {{- with $c.servfail }}{{- with .duration }}
  servfail {{ . }}
  {{- end }}{{- end }}
  {{- if and $c.disable $c.disable.success }}
  disable success{{- with $c.disable.successZones }} {{ join " " . }}{{- end }}
  {{- end }}
  {{- if and $c.disable $c.disable.denial }}
  disable denial{{- with $c.disable.denialZones }} {{ join " " . }}{{- end }}
  {{- end }}
  {{- if $c.keepttl }}
  keepttl
  {{- end }}
}
{{- end }}
{{- end -}}

{{/*
Render a CoreDNS forward directive. Call via include with a dict context:
  (dict "zone" $zone)
The zone's forward config is read from $zone.forward, a structured map that mirrors
the CoreDNS forward block parameters (https://coredns.io/plugins/forward/). Only a
representative subset of parameters is wired up today; extend it by appending one line
to the option list below, plus a documented key in values.yaml and values.schema.json.
*/}}
{{- define "coredns.forwardBlock" -}}
{{- $f := .zone.forward | default dict }}
{{- $upstreams := $f.to }}
{{- if $upstreams }}
{{- $lines := list }}
{{- with $f.except }}{{ $lines = append $lines (printf "except %s" (join " " .)) }}{{ end }}
{{- if $f.forceTCP }}{{ $lines = append $lines "force_tcp" }}{{ end }}
{{- if $f.preferUDP }}{{ $lines = append $lines "prefer_udp" }}{{ end }}
{{- with $f.expire }}{{ $lines = append $lines (printf "expire %v" .) }}{{ end }}
{{- with $f.maxAge }}{{ $lines = append $lines (printf "max_age %v" .) }}{{ end }}
{{- if not (kindIs "invalid" $f.maxIdleConns) }}{{ $lines = append $lines (printf "max_idle_conns %v" $f.maxIdleConns) }}{{ end }}
{{- if not (kindIs "invalid" $f.maxFails) }}{{ $lines = append $lines (printf "max_fails %v" $f.maxFails) }}{{ end }}
{{- if not (kindIs "invalid" $f.maxConnectAttempts) }}{{ $lines = append $lines (printf "max_connect_attempts %v" $f.maxConnectAttempts) }}{{ end }}
{{- with $f.dohMethod }}{{ $lines = append $lines (printf "doh_method %v" .) }}{{ end }}
{{- with $f.tls }}
{{- if and .cert .key .ca }}{{ $lines = append $lines (printf "tls %s %s %s" .cert .key .ca) }}
{{- else if and .cert .key }}{{ $lines = append $lines (printf "tls %s %s" .cert .key) }}
{{- else if .ca }}{{ $lines = append $lines (printf "tls %s" .ca) }}
{{- else if .enabled }}{{ $lines = append $lines "tls" }}{{ end }}
{{- end }}
{{- with $f.tlsServername }}{{ $lines = append $lines (printf "tls_servername %v" .) }}{{ end }}
{{- with $f.policy }}{{ $lines = append $lines (printf "policy %v" .) }}{{ end }}
{{- with $f.healthCheck }}{{ $lines = append $lines (printf "health_check %v" .) }}{{ end }}
{{- if not (kindIs "invalid" $f.maxConcurrent) }}{{ $lines = append $lines (printf "max_concurrent %v" $f.maxConcurrent) }}{{ end }}
{{- with $f.next }}{{ $lines = append $lines (printf "next %s" (join " " .)) }}{{ end }}
{{- if $f.nextOnNodata }}{{ $lines = append $lines "next_on_nodata" }}{{ end }}
{{- if $f.failfastAllUnhealthyUpstreams }}{{ $lines = append $lines "failfast_all_unhealthy_upstreams" }}{{ end }}
{{- with $f.failover }}{{ $lines = append $lines (printf "failover %s" (join " " .)) }}{{ end }}
{{- with $f.resolver }}{{ $lines = append $lines (printf "resolver %s" (join " " .)) }}{{ end }}
{{- printf "forward . %s" (join " " $upstreams) }}{{ if $lines }} {
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
  (dict "zone" $zone)
The zone names come from $zone.names (joined) and the optional reverse (PTR) ranges
from $zone.cidrs. Kubernetes-plugin parameters are read from $zone.kubernetes, a
structured map that mirrors the CoreDNS kubernetes block parameters
(https://coredns.io/plugins/kubernetes/). Only a representative subset of parameters
is wired up today; extend it by appending one line below, plus a documented key in
values.yaml and values.schema.json.
*/}}
{{- define "coredns.kubernetesBlock" -}}
{{- $k := .zone.kubernetes | default dict -}}
{{- $cidrs := join " " (.zone.cidrs | default list) -}}
kubernetes {{ join " " .zone.names }}{{ with $cidrs }} {{ . }}{{ end }} {
  {{- with $k.endpoint }}
  endpoint {{ . }}
  {{- end }}
  {{- with $k.tls }}{{- if and .cert .key .ca }}
  tls {{ .cert }} {{ .key }} {{ .ca }}
  {{- end }}{{- end }}
  {{- with $k.kubeconfig }}{{- with .path }}
  kubeconfig {{ . }}{{- with $k.kubeconfig.context }} {{ . }}{{- end }}
  {{- end }}{{- end }}
  {{- with $k.apiserverQPS }}
  apiserver_qps {{ . }}
  {{- end }}
  {{- with $k.apiserverBurst }}
  apiserver_burst {{ . }}
  {{- end }}
  {{- with $k.apiserverMaxInflight }}
  apiserver_max_inflight {{ . }}
  {{- end }}
  {{- with $k.namespaces }}
  namespaces {{ join " " . }}
  {{- end }}
  {{- with $k.namespaceLabels }}
  namespace_labels {{ . }}
  {{- end }}
  {{- with $k.labels }}
  labels {{ . }}
  {{- end }}
  pods {{ $k.pods | default "verified" }}
  {{- if $k.endpointPodNames }}
  endpoint_pod_names
  {{- end }}
  {{- with $k.ttl }}
  ttl {{ . }}
  {{- end }}
  {{- if $k.noendpoints }}
  noendpoints
  {{- end }}
  {{- if $k.fallthroughZones }}
  fallthrough {{ join " " $k.fallthroughZones }}
  {{- else if $k.fallthrough }}
  fallthrough
  {{- end }}
  {{- if $k.ignoreEmptyService }}
  ignore empty_service
  {{- end }}
  {{- with $k.multicluster }}
  multicluster {{ join " " . }}
  {{- end }}
  {{- with $k.startupTimeout }}
  startup_timeout {{ . }}
  {{- end }}
}
{{- end -}}

{{/*
Render the CoreDNS log directive. Call via include with a dict context:
  (dict "zone" $zone)
The zone's log classes are read from $zone.log (a list). When absent, the built-in
default (denial, error) applies. An empty list disables logging for the zone.
*/}}
{{- define "coredns.logBlock" -}}
{{- $classes := .zone.log }}
{{- if kindIs "invalid" $classes }}{{ $classes = list "denial" "error" }}{{ end }}
{{- if $classes -}}
log . {
{{- range $classes }}
  class {{ . }}
{{- end }}
}
{{- end }}
{{- end -}}

{{/*
Render the CoreDNS loadbalance directive. Call via include with a dict context:
  (dict "zone" $zone)
The zone's policy is read from $zone.loadbalance. When absent, the built-in default
round_robin applies.
*/}}
{{- define "coredns.loadbalanceBlock" -}}
{{- $policy := .zone.loadbalance | default "round_robin" -}}
loadbalance {{ $policy }}
{{- end -}}

{{/*
Render the CoreDNS rewrite directives. Call via include with a dict context:
  (dict "zone" $zone)
Each $zone.rewrite entry renders as "rewrite name MATCH FROM TO" (match defaults to exact).
*/}}
{{- define "coredns.rewriteBlock" -}}
{{- range $i, $r := (.zone.rewrite | default list) }}
{{- if $i }}{{ "\n" }}{{ end -}}
{{- $match := $r.match | default "exact" -}}
rewrite name {{ $match }} {{ $r.from }} {{ $r.to }}{{ if ne $match "exact" }} answer auto{{ end }}
{{- end }}
{{- end -}}
