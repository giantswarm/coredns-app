# coredns-app

A Helm chart for CoreDNS

**Homepage:** <https://github.com/giantswarm/coredns-app>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| name | string | `"coredns"` | Name used for the CoreDNS workload and its resources. |
| namespace | string | `"kube-system"` | Namespace the CoreDNS resources are deployed into. |
| serviceType | string | `"managed"` | Giant Swarm service type label applied to the resources. |
| securityContext | object | `{"runAsGroup":33,"runAsUser":33}` | Pod-level security context for the CoreDNS containers. |
| securityContext.runAsUser | int | `33` | UID the CoreDNS process runs as. |
| securityContext.runAsGroup | int | `33` | GID the CoreDNS process runs as. |
| service | object | `{"clusterIP":"172.31.0.10"}` | Configuration for the CoreDNS Service. |
| service.clusterIP | string | `"172.31.0.10"` | Cluster IP of the DNS Service. |
| image | object | `{"name":"giantswarm/coredns","registry":"gsoci.azurecr.io","tag":"1.15.0"}` | Container image for CoreDNS. |
| image.registry | string | `"gsoci.azurecr.io"` | Image registry. |
| image.name | string | `"giantswarm/coredns"` | Image repository. |
| image.tag | string | `"1.15.0"` | Image tag. |
| ports | object | `{"dns":{"name":"dns","port":53,"targetPort":1053},"metrics":{"port":9153}}` | Ports exposed by CoreDNS. |
| ports.dns | object | `{"name":"dns","port":53,"targetPort":1053}` | DNS port configuration. |
| ports.dns.name | string | `"dns"` | Port name. |
| ports.dns.targetPort | int | `1053` | Container port CoreDNS listens on. |
| ports.dns.port | int | `53` | Service port exposed for DNS. |
| ports.metrics | object | `{"port":9153}` | Prometheus metrics port configuration. |
| ports.metrics.port | int | `9153` | Port for the Prometheus metrics endpoint. |
| resources | object | `{"limits":{"memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Resource requests and limits for the CoreDNS containers. |
| resources.limits | object | `{"memory":"1Gi"}` | Resource limits. |
| resources.limits.memory | string | `"1Gi"` | Memory limit. |
| resources.requests | object | `{"cpu":"250m","memory":"512Mi"}` | Resource requests. |
| resources.requests.cpu | string | `"250m"` | CPU request. |
| resources.requests.memory | string | `"512Mi"` | Memory request. |
| updateStrategy | object | `{"rollingUpdate":{"maxUnavailable":1},"type":"RollingUpdate"}` | Update strategy for the CoreDNS workloads. |
| updateStrategy.type | string | `"RollingUpdate"` | Update strategy type. |
| updateStrategy.rollingUpdate | object | `{"maxUnavailable":1}` | Rolling update parameters. |
| updateStrategy.rollingUpdate.maxUnavailable | int | `1` | Maximum number of pods that can be unavailable during the update. |
| podDisruptionBudget | object | `{"maxUnavailable":"25%"}` | Pod disruption budget for the CoreDNS workloads. |
| podDisruptionBudget.maxUnavailable | string | `"25%"` | Maximum number of pods that can be unavailable to voluntary disruptions. |
| hpa | object | `{"behavior":{"scaleDown":{"stabilizationWindowSeconds":1800}},"enabled":true,"maxReplicas":50,"metrics":[],"minReplicas":2,"targetCPUUtilizationPercentage":80,"targetMemoryUtilizationPercentage":0}` | Horizontal Pod Autoscaler configuration. |
| hpa.enabled | bool | `true` | Enable the HorizontalPodAutoscaler. |
| hpa.minReplicas | int | `2` | Minimum number of replicas. |
| hpa.maxReplicas | int | `50` | Maximum number of replicas. |
| hpa.targetCPUUtilizationPercentage | int | `80` | Target average CPU utilization percentage. |
| hpa.targetMemoryUtilizationPercentage | int | `0` | Target average memory utilization percentage. Set to 0 to disable the memory metric. |
| hpa.metrics | list | `[]` | Additional custom metrics for the HPA (autoscaling/v2 metric objects). |
| hpa.behavior | object | `{"scaleDown":{"stabilizationWindowSeconds":1800}}` | Scaling behavior. The stabilization window restricts replica-count flapping when the scaling metrics keep fluctuating. |
| hpa.behavior.scaleDown | object | `{"stabilizationWindowSeconds":1800}` | Scale-down behavior. |
| hpa.behavior.scaleDown.stabilizationWindowSeconds | int | `1800` | Seconds to consider while scaling down to prevent flapping. |
| controlPlane | object | `{"enabled":true,"nodeSelector":{"node-role.kubernetes.io/control-plane":""},"tolerations":[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"},{"effect":"NoSchedule","key":"node-role.kubernetes.io/control-plane","operator":"Exists"},{"key":"node.cloudprovider.kubernetes.io/uninitialized","operator":"Exists"}]}` | Control-plane CoreDNS instance configuration. |
| controlPlane.enabled | bool | `true` | Whether to deploy the control-plane CoreDNS instance. |
| controlPlane.nodeSelector | object | `{"node-role.kubernetes.io/control-plane":""}` | Node selector for the control-plane CoreDNS instance. |
| controlPlane.tolerations | list | `[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"},{"effect":"NoSchedule","key":"node-role.kubernetes.io/control-plane","operator":"Exists"},{"key":"node.cloudprovider.kubernetes.io/uninitialized","operator":"Exists"}]` | Tolerations for the control-plane CoreDNS instance. |
| coredns | object | `{"additionalZones":[],"cluster":{"cache":{"denial":{"capacity":9984,"minTTL":null,"ttl":5},"disable":{"denial":null,"denialZones":[],"success":null,"successZones":[]},"keepttl":false,"prefetch":{"amount":null,"duration":null,"percentage":null},"serveStale":{"duration":null,"enabled":false,"refreshMode":null,"verifyTimeout":null},"servfail":{"duration":null},"success":{"capacity":9984,"minTTL":null,"ttl":30},"ttl":null,"zones":[]},"domains":["cluster.local"],"kubernetes":{"apiserverBurst":null,"apiserverMaxInflight":null,"apiserverQPS":null,"endpoint":null,"endpointPodNames":false,"fallthrough":false,"fallthroughZones":[],"ignoreEmptyService":false,"kubeconfig":{"context":null,"path":null},"labels":null,"multicluster":[],"namespaceLabels":null,"namespaces":[],"noendpoints":false,"pods":"verified","startupTimeout":null,"tls":{"ca":null,"cert":null,"key":null},"ttl":null},"loadbalance":"round_robin","log":["denial","error"],"podCIDR":"192.168.0.0/16","serviceCIDR":"172.31.0.0/16"},"custom":"","public":{"autopath":"","cache":{"denial":{"capacity":9984,"minTTL":null,"ttl":5},"disable":{"denial":null,"denialZones":[],"success":null,"successZones":[]},"keepttl":false,"prefetch":{"amount":null,"duration":null,"percentage":null},"serveStale":{"duration":null,"enabled":false,"refreshMode":null,"verifyTimeout":null},"servfail":{"duration":null},"success":{"capacity":9984,"minTTL":null,"ttl":30},"ttl":null,"zones":[]},"forward":{"dohMethod":null,"except":[],"expire":null,"failfastAllUnhealthyUpstreams":false,"failover":[],"forceTCP":false,"healthCheck":null,"maxAge":null,"maxConcurrent":null,"maxConnectAttempts":null,"maxFails":null,"maxIdleConns":null,"next":[],"nextOnNodata":false,"policy":null,"preferUDP":false,"resolver":[],"tls":{"ca":null,"cert":null,"enabled":false,"key":null},"tlsServername":null,"to":[]},"loadbalance":"round_robin","log":["denial","error"]}}` | CoreDNS Corefile configuration. Cache, log and loadbalance are configured per zone, so different zones can behave differently. A zone that omits cache falls back to the built-in defaults (success 9984 30 / denial 9984 5); a zone that omits log/loadbalance falls back to denial+error / round_robin. |
| coredns.public | object | `{"autopath":"","cache":{"denial":{"capacity":9984,"minTTL":null,"ttl":5},"disable":{"denial":null,"denialZones":[],"success":null,"successZones":[]},"keepttl":false,"prefetch":{"amount":null,"duration":null,"percentage":null},"serveStale":{"duration":null,"enabled":false,"refreshMode":null,"verifyTimeout":null},"servfail":{"duration":null},"success":{"capacity":9984,"minTTL":null,"ttl":30},"ttl":null,"zones":[]},"forward":{"dohMethod":null,"except":[],"expire":null,"failfastAllUnhealthyUpstreams":false,"failover":[],"forceTCP":false,"healthCheck":null,"maxAge":null,"maxConcurrent":null,"maxConnectAttempts":null,"maxFails":null,"maxIdleConns":null,"next":[],"nextOnNodata":false,"policy":null,"preferUDP":false,"resolver":[],"tls":{"ca":null,"cert":null,"enabled":false,"key":null},"tlsServername":null,"to":[]},"loadbalance":"round_robin","log":["denial","error"]}` | The "." zone — external/public DNS served by the forward plugin. |
| coredns.public.cache | object | `{"denial":{"capacity":9984,"minTTL":null,"ttl":5},"disable":{"denial":null,"denialZones":[],"success":null,"successZones":[]},"keepttl":false,"prefetch":{"amount":null,"duration":null,"percentage":null},"serveStale":{"duration":null,"enabled":false,"refreshMode":null,"verifyTimeout":null},"servfail":{"duration":null},"success":{"capacity":9984,"minTTL":null,"ttl":30},"ttl":null,"zones":[]}` | Cache plugin configuration for this zone (https://coredns.io/plugins/cache/). |
| coredns.public.cache.ttl | string | `nil` | Top-level TTL cap applied before the success/denial checks (seconds). |
| coredns.public.cache.zones | list | `[]` | Cache ZONES — limit caching to these zones. Empty means the server-block zones. |
| coredns.public.cache.success | object | `{"capacity":9984,"minTTL":null,"ttl":30}` | Caching of positive (success) responses. |
| coredns.public.cache.success.capacity | int | `9984` | Maximum number of cached positive responses. |
| coredns.public.cache.success.ttl | int | `30` | Max TTL for positive responses (seconds). |
| coredns.public.cache.success.minTTL | string | `nil` | Min TTL for positive responses (seconds). |
| coredns.public.cache.denial | object | `{"capacity":9984,"minTTL":null,"ttl":5}` | Caching of negative (NXDOMAIN/NODATA) responses. |
| coredns.public.cache.denial.capacity | int | `9984` | Maximum number of cached negative responses. |
| coredns.public.cache.denial.ttl | int | `5` | Max TTL for negative responses (seconds). |
| coredns.public.cache.denial.minTTL | string | `nil` | Min TTL for negative responses (seconds). |
| coredns.public.cache.prefetch | object | `{"amount":null,"duration":null,"percentage":null}` | Prefetch popular entries before they expire. |
| coredns.public.cache.prefetch.amount | string | `nil` | Prefetch when at least this many requests are received (enables prefetch). |
| coredns.public.cache.prefetch.duration | string | `nil` | Only prefetch if the item was requested within this duration. |
| coredns.public.cache.prefetch.percentage | string | `nil` | Only prefetch if this percentage of the TTL remains (requires duration). |
| coredns.public.cache.serveStale | object | `{"duration":null,"enabled":false,"refreshMode":null,"verifyTimeout":null}` | Serve stale answers while refreshing in the background. |
| coredns.public.cache.serveStale.enabled | bool | `false` | Enable serving stale answers. |
| coredns.public.cache.serveStale.duration | string | `nil` | How long stale answers may be served. |
| coredns.public.cache.serveStale.refreshMode | string | `nil` | Refresh mode. |
| coredns.public.cache.serveStale.verifyTimeout | string | `nil` | With refreshMode verify — max wait for upstream verify before serving stale. |
| coredns.public.cache.servfail | object | `{"duration":null}` | SERVFAIL caching. |
| coredns.public.cache.servfail.duration | string | `nil` | How long to cache SERVFAIL responses. |
| coredns.public.cache.disable | object | `{"denial":null,"denialZones":[],"success":null,"successZones":[]}` | Selectively disable caching. |
| coredns.public.cache.disable.success | string | `nil` | Disable caching of positive responses. |
| coredns.public.cache.disable.successZones | list | `[]` | Limit the success disable to these zones. |
| coredns.public.cache.disable.denial | string | `nil` | Disable caching of negative responses. |
| coredns.public.cache.disable.denialZones | list | `[]` | Limit the denial disable to these zones. |
| coredns.public.cache.keepttl | bool | `false` | Preserve original TTLs instead of counting them down. |
| coredns.public.forward | object | `{"dohMethod":null,"except":[],"expire":null,"failfastAllUnhealthyUpstreams":false,"failover":[],"forceTCP":false,"healthCheck":null,"maxAge":null,"maxConcurrent":null,"maxConnectAttempts":null,"maxFails":null,"maxIdleConns":null,"next":[],"nextOnNodata":false,"policy":null,"preferUDP":false,"resolver":[],"tls":{"ca":null,"cert":null,"enabled":false,"key":null},"tlsServername":null,"to":[]}` | Forward plugin configuration (https://coredns.io/plugins/forward/). The FROM is always ".". Only a representative subset of parameters is wired up today; leave a key unset to keep the CoreDNS default. |
| coredns.public.forward.to | list | `[]` | Upstream DNS servers (the forward TO targets). Empty means use /etc/resolv.conf. |
| coredns.public.forward.except | list | `[]` | except NAMES — domains to pass through unforwarded. |
| coredns.public.forward.forceTCP | bool | `false` | force_tcp — always use TCP to the upstream. |
| coredns.public.forward.preferUDP | bool | `false` | prefer_udp — try UDP first even for queries received over TCP. |
| coredns.public.forward.expire | string | `nil` | expire — close idle upstream connections after this duration. |
| coredns.public.forward.maxAge | string | `nil` | max_age — replace connections after this total lifetime. Must not be less than expire. |
| coredns.public.forward.maxIdleConns | string | `nil` | max_idle_conns — idle connections cached per upstream (0 = unlimited). |
| coredns.public.forward.maxFails | string | `nil` | max_fails — consecutive failed health checks before marking an upstream down. |
| coredns.public.forward.maxConnectAttempts | string | `nil` | max_connect_attempts — cap on connect attempts per request (0 = no cap). |
| coredns.public.forward.dohMethod | string | `nil` | doh_method — HTTP method for DoH requests. |
| coredns.public.forward.tls | object | `{"ca":null,"cert":null,"enabled":false,"key":null}` | tls CERT KEY CA — set cert+key, ca, all three, or enabled for bare tls. |
| coredns.public.forward.tls.enabled | bool | `false` | Emit bare "tls" (system CAs, no client auth). |
| coredns.public.forward.tls.cert | string | `nil` | Client cert file path. |
| coredns.public.forward.tls.key | string | `nil` | Client key file path. |
| coredns.public.forward.tls.ca | string | `nil` | CA cert file path. |
| coredns.public.forward.tlsServername | string | `nil` | tls_servername NAME — expected server cert name (e.g. dns.quad9.net). |
| coredns.public.forward.policy | string | `nil` | policy — upstream selection policy. |
| coredns.public.forward.healthCheck | string | `nil` | health_check DURATION [no_rec] [domain FQDN]. |
| coredns.public.forward.maxConcurrent | string | `nil` | max_concurrent — maximum number of concurrent queries to forward. |
| coredns.public.forward.next | list | `[]` | next RCODE... — run the next forward plugin on these rcodes (e.g. [NXDOMAIN]). |
| coredns.public.forward.nextOnNodata | bool | `false` | next_on_nodata — run the next forward plugin on empty NOERROR answers. |
| coredns.public.forward.failfastAllUnhealthyUpstreams | bool | `false` | failfast_all_unhealthy_upstreams — SERVFAIL when all upstreams are down. |
| coredns.public.forward.failover | list | `[]` | failover RCODE... — retry the next upstream on these rcodes (e.g. [SERVFAIL, REFUSED]). |
| coredns.public.forward.resolver | list | `[]` | resolver IP[:PORT]... — resolvers for hostname-based "to" endpoints. |
| coredns.public.log | list | `["denial","error"]` | CoreDNS log classes for this zone. |
| coredns.public.loadbalance | string | `"round_robin"` | Load balancing policy. |
| coredns.public.autopath | string | `""` | autopath plugin args, e.g. "@kubernetes". Empty disables autopath. |
| coredns.cluster | object | `{"cache":{"denial":{"capacity":9984,"minTTL":null,"ttl":5},"disable":{"denial":null,"denialZones":[],"success":null,"successZones":[]},"keepttl":false,"prefetch":{"amount":null,"duration":null,"percentage":null},"serveStale":{"duration":null,"enabled":false,"refreshMode":null,"verifyTimeout":null},"servfail":{"duration":null},"success":{"capacity":9984,"minTTL":null,"ttl":30},"ttl":null,"zones":[]},"domains":["cluster.local"],"kubernetes":{"apiserverBurst":null,"apiserverMaxInflight":null,"apiserverQPS":null,"endpoint":null,"endpointPodNames":false,"fallthrough":false,"fallthroughZones":[],"ignoreEmptyService":false,"kubeconfig":{"context":null,"path":null},"labels":null,"multicluster":[],"namespaceLabels":null,"namespaces":[],"noendpoints":false,"pods":"verified","startupTimeout":null,"tls":{"ca":null,"cert":null,"key":null},"ttl":null},"loadbalance":"round_robin","log":["denial","error"],"podCIDR":"192.168.0.0/16","serviceCIDR":"172.31.0.0/16"}` | The cluster.local zone — in-cluster DNS served by the kubernetes plugin. |
| coredns.cluster.domains | list | `["cluster.local"]` | Zone names served by this block. |
| coredns.cluster.serviceCIDR | string | `"172.31.0.0/16"` | Service CIDR for the reverse zone. |
| coredns.cluster.podCIDR | string | `"192.168.0.0/16"` | Pod CIDR for the reverse zone. |
| coredns.cluster.cache | object | `{"denial":{"capacity":9984,"minTTL":null,"ttl":5},"disable":{"denial":null,"denialZones":[],"success":null,"successZones":[]},"keepttl":false,"prefetch":{"amount":null,"duration":null,"percentage":null},"serveStale":{"duration":null,"enabled":false,"refreshMode":null,"verifyTimeout":null},"servfail":{"duration":null},"success":{"capacity":9984,"minTTL":null,"ttl":30},"ttl":null,"zones":[]}` | Cache plugin configuration for this zone (https://coredns.io/plugins/cache/). |
| coredns.cluster.cache.ttl | string | `nil` | Top-level TTL cap applied before the success/denial checks (seconds). |
| coredns.cluster.cache.zones | list | `[]` | Cache ZONES — limit caching to these zones. Empty means the server-block zones. |
| coredns.cluster.cache.success | object | `{"capacity":9984,"minTTL":null,"ttl":30}` | Caching of positive (success) responses. |
| coredns.cluster.cache.success.capacity | int | `9984` | Maximum number of cached positive responses. |
| coredns.cluster.cache.success.ttl | int | `30` | Max TTL for positive responses (seconds). |
| coredns.cluster.cache.success.minTTL | string | `nil` | Min TTL for positive responses (seconds). |
| coredns.cluster.cache.denial | object | `{"capacity":9984,"minTTL":null,"ttl":5}` | Caching of negative (NXDOMAIN/NODATA) responses. |
| coredns.cluster.cache.denial.capacity | int | `9984` | Maximum number of cached negative responses. |
| coredns.cluster.cache.denial.ttl | int | `5` | Max TTL for negative responses (seconds). |
| coredns.cluster.cache.denial.minTTL | string | `nil` | Min TTL for negative responses (seconds). |
| coredns.cluster.cache.prefetch | object | `{"amount":null,"duration":null,"percentage":null}` | Prefetch popular entries before they expire. |
| coredns.cluster.cache.prefetch.amount | string | `nil` | Prefetch when at least this many requests are received (enables prefetch). |
| coredns.cluster.cache.prefetch.duration | string | `nil` | Only prefetch if the item was requested within this duration. |
| coredns.cluster.cache.prefetch.percentage | string | `nil` | Only prefetch if this percentage of the TTL remains (requires duration). |
| coredns.cluster.cache.serveStale | object | `{"duration":null,"enabled":false,"refreshMode":null,"verifyTimeout":null}` | Serve stale answers while refreshing in the background. |
| coredns.cluster.cache.serveStale.enabled | bool | `false` | Enable serving stale answers. |
| coredns.cluster.cache.serveStale.duration | string | `nil` | How long stale answers may be served. |
| coredns.cluster.cache.serveStale.refreshMode | string | `nil` | Refresh mode. |
| coredns.cluster.cache.serveStale.verifyTimeout | string | `nil` | With refreshMode verify — max wait for upstream verify before serving stale. |
| coredns.cluster.cache.servfail | object | `{"duration":null}` | SERVFAIL caching. |
| coredns.cluster.cache.servfail.duration | string | `nil` | How long to cache SERVFAIL responses. |
| coredns.cluster.cache.disable | object | `{"denial":null,"denialZones":[],"success":null,"successZones":[]}` | Selectively disable caching. |
| coredns.cluster.cache.disable.success | string | `nil` | Disable caching of positive responses. |
| coredns.cluster.cache.disable.successZones | list | `[]` | Limit the success disable to these zones. |
| coredns.cluster.cache.disable.denial | string | `nil` | Disable caching of negative responses. |
| coredns.cluster.cache.disable.denialZones | list | `[]` | Limit the denial disable to these zones. |
| coredns.cluster.cache.keepttl | bool | `false` | Preserve original TTLs instead of counting them down. |
| coredns.cluster.kubernetes | object | `{"apiserverBurst":null,"apiserverMaxInflight":null,"apiserverQPS":null,"endpoint":null,"endpointPodNames":false,"fallthrough":false,"fallthroughZones":[],"ignoreEmptyService":false,"kubeconfig":{"context":null,"path":null},"labels":null,"multicluster":[],"namespaceLabels":null,"namespaces":[],"noendpoints":false,"pods":"verified","startupTimeout":null,"tls":{"ca":null,"cert":null,"key":null},"ttl":null}` | Kubernetes plugin configuration (https://coredns.io/plugins/kubernetes/). Leave a key unset to keep the CoreDNS default. |
| coredns.cluster.kubernetes.pods | string | `"verified"` | pods — pod record mode. |
| coredns.cluster.kubernetes.endpoint | string | `nil` | endpoint URL — remote k8s API endpoint (omit for in-cluster). |
| coredns.cluster.kubernetes.tls | object | `{"ca":null,"cert":null,"key":null}` | tls CERT KEY CACERT — for a remote k8s connection. |
| coredns.cluster.kubernetes.tls.cert | string | `nil` | Client cert file path. |
| coredns.cluster.kubernetes.tls.key | string | `nil` | Client key file path. |
| coredns.cluster.kubernetes.tls.ca | string | `nil` | CA cert file path. |
| coredns.cluster.kubernetes.kubeconfig | object | `{"context":null,"path":null}` | kubeconfig KUBECONFIG [CONTEXT] — authenticate via a kubeconfig file. |
| coredns.cluster.kubernetes.kubeconfig.path | string | `nil` | Path to the kubeconfig file. |
| coredns.cluster.kubernetes.kubeconfig.context | string | `nil` | Context within the kubeconfig file. |
| coredns.cluster.kubernetes.apiserverQPS | string | `nil` | apiserver_qps — max queries-per-second to the API server. |
| coredns.cluster.kubernetes.apiserverBurst | string | `nil` | apiserver_burst — max burst size for API server requests. |
| coredns.cluster.kubernetes.apiserverMaxInflight | string | `nil` | apiserver_max_inflight — max concurrent in-flight API server requests. |
| coredns.cluster.kubernetes.ttl | string | `nil` | ttl SECONDS (0–3600). |
| coredns.cluster.kubernetes.endpointPodNames | bool | `false` | endpoint_pod_names — use the pod name instead of the dashed IP. |
| coredns.cluster.kubernetes.noendpoints | bool | `false` | noendpoints — disable endpoint record serving. |
| coredns.cluster.kubernetes.namespaces | list | `[]` | namespaces NAMESPACE... — expose only these namespaces. |
| coredns.cluster.kubernetes.namespaceLabels | string | `nil` | namespace_labels EXPRESSION — expose only namespaces matching the selector. |
| coredns.cluster.kubernetes.labels | string | `nil` | labels EXPRESSION — expose only objects matching the selector. |
| coredns.cluster.kubernetes.ignoreEmptyService | bool | `false` | ignore empty_service — NXDOMAIN for services without ready endpoints. |
| coredns.cluster.kubernetes.fallthrough | bool | `false` | fallthrough — pass unresolved queries to the next plugin (all zones). |
| coredns.cluster.kubernetes.fallthroughZones | list | `[]` | fallthrough ZONES... — limit fallthrough to these zones. |
| coredns.cluster.kubernetes.multicluster | list | `[]` | multicluster ZONES... — MCS-API multicluster zones. |
| coredns.cluster.kubernetes.startupTimeout | string | `nil` | startup_timeout — wait for informer cache sync at startup. |
| coredns.cluster.log | list | `["denial","error"]` | CoreDNS log classes for this zone. |
| coredns.cluster.loadbalance | string | `"round_robin"` | Load balancing policy. |
| coredns.additionalZones | list | `[]` | Additional fully-templated local zones. Each entry is its own CoreDNS server block and renders whichever of forward/kubernetes it declares (or both, or neither). Per-entry keys: names (required), cidrs, cache, forward, kubernetes, log, loadbalance — same shapes as coredns.public/coredns.cluster. |
| coredns.custom | string | `""` | Raw Corefile snippet appended verbatim at the end of the configuration. |
| adopter | object | `{"enabled":false,"image":"gsoci.azurecr.io/giantswarm/docker-kubectl:1.37.1","tolerations":[{"operator":"Exists"}]}` | Adopter job that takes ownership of pre-existing CoreDNS resources. |
| adopter.enabled | bool | `false` | Enable the adopter job. |
| adopter.image | string | `"gsoci.azurecr.io/giantswarm/docker-kubectl:1.37.1"` | Image used by the adopter job. |
| adopter.tolerations | list | `[{"operator":"Exists"}]` | Tolerations for the adopter job. |
| tolerations | list | `[{"key":"node.cloudprovider.kubernetes.io/uninitialized","operator":"Exists"},{"key":"node.cluster.x-k8s.io/uninitialized","operator":"Exists"}]` | Tolerations for the CoreDNS workers. |
