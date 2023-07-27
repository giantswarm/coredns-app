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
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "labels.selector" -}}
k8s-app: {{ .Values.name | quote }}
{{- end -}}

{{- define "cloudprovider.zones" -}}
{{- if hasKey .Values.cloudSpecificSettings .Values.provider -}}
  {{- $cloudProviderConfig := get .Values.cloudSpecificSettings .Values.provider}}
  {{- $zones := get $cloudProviderConfig "defaultZones" }}
  {{- $zones = concat $zones .Values.cloudSpecificSettings.additionalZones}}
  {{- $global := . }}
(forwardtocloudprovider) {
    cache
    errors
    template ANY AAAA {
      rcode NOERROR
    }
    health {
      lameduck 5s
    }
    ready
    log . {
      {{- range ($global.Values.configmap.log | trimAll "\n " |  split "\n") }}
      class {{ . }}
      {{- end }}
    }
    loadbalance {{ $global.Values.loadbalancePolicy }}

    forward . {{ join " " $cloudProviderConfig.forwardIPs }}
}
  {{- range $zone := $zones }}
{{ $zone }}:{{ $global.Values.ports.dns.targetPort }} {
    import forwardtocloudprovider
}
{{- end -}}
{{- end -}}
{{- end -}}
