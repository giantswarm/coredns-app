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

{{- define "cloudprovider.forward" -}}
{{- if hasKey .Values.cloudSpecificSettings .Values.Installation.V1.Provider.Kind -}}
{{- $cloudProviderConfig := get .Values.cloudSpecificSettings .Values.Installation.V1.Provider.Kind}}
  {{- $zones := get $cloudProviderConfig "defaultZones" }}
  {{- $zones = concat $zones .Values.cloudSpecificSettings.additionalZones}}
  {{- $global := . }}
  {{- range $zone := $zones }}
    forward {{ $zone }} {{ join " " $cloudProviderConfig.forwardIPs }}
  {{- end -}}
{{- end -}}
{{- end -}}
