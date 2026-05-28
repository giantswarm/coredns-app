# Values Interface Refactor

This document describes the restructured values interface introduced in this chart. The refactor is backward compatible — existing installs continue to work unchanged.

---

## Motivation

The previous `values.yaml` had grown organically. Key problems:

- Values that control **Corefile content** were scattered across three separate sections (`loadbalancePolicy`, `additionalLocalZones`, `cluster.*`, `configmap.*`), with no zone-awareness
- `ports.prometheus` was a bare integer while `ports.dns` was a structured object (type inconsistency)
- `userID` / `groupID` were orphaned at the root instead of under a security context
- `mastersInstance` was non-standard naming; `cluster.kubernetes.DNS.IP` (a Service setting) lived inside cluster topology
- `configmap.cache: 30` was defined but never rendered in templates — CoreDNS ran with a 3600s success TTL instead of the intended 30s

---

## Approach

Introduce a new top-level key **`.Values.coredns`** that holds all CoreDNS Corefile configuration in a zone-aware structure. All existing keys are kept and continue to work. New keys have **no defaults** in `values.yaml` — templates fall back to old paths automatically when new keys are unset, so old overrides are never silently ignored.

---

## New Canonical Structure

### `.Values.coredns` — all Corefile-related config

```yaml
coredns:
  cache:
    successTTL: 30       # max TTL for positive responses (seconds) — defaults to configmap.cache
    denialTTL: 5         # max TTL for NXDOMAIN/NODATA responses (seconds)
    prefetch: 0          # prefetch popular items before TTL expires (0 = disabled)
    serveStale: false    # serve stale answers while refreshing in background

  log:                   # list of log classes — defaults to configmap.log
    - denial
    - error

  loadbalance: round_robin   # round_robin | random — defaults to loadbalancePolicy

  # "." zone — external/public DNS (forward zone)
  public:
    upstreams: []        # upstream DNS servers; empty = /etc/resolv.conf
    options: ""          # raw forward plugin options (max_fails, health_check, etc.)
    autopath: ""         # autopath plugin args (optional)

  # cluster.local zone — in-cluster DNS (kubernetes plugin)
  cluster:
    domains:             # list of local domains — defaults to cluster.kubernetes.clusterDomain
      - cluster.local
    serviceCIDR: 172.31.0.0/16   # k8s service IP range — defaults to cluster.kubernetes.API.clusterIPRange
    podCIDR: 192.168.0.0/16      # pod network CIDR — defaults to cluster.calico.CIDR

  additionalLocalZones: []  # extra zones (kubernetes plugin, no CIDR ranges)

  custom: ""  # raw Corefile snippet appended verbatim at end
```

### Other new paths (non-Corefile restructuring)

```yaml
# DNS Service ClusterIP  (was: cluster.kubernetes.DNS.IP)
service:
  clusterIP: 172.31.0.10

# Pod security context  (was: top-level userID / groupID)
securityContext:
  runAsUser: 33
  runAsGroup: 33

# Metrics port as structured object  (was: ports.prometheus bare int)
ports:
  metrics:
    port: 9153

# Control-plane deployment toggle  (was: mastersInstance)
controlPlane:
  enabled: true
  nodeSelector:
    node-role.kubernetes.io/control-plane: ""
```

---

## Migration Map (old path → new path)

| Old path | Old type | New path | New type |
|---|---|---|---|
| `configmap.cache` (was unused in template) | int | `coredns.cache.successTTL` | int |
| _(no equivalent)_ | — | `coredns.cache.denialTTL` | int |
| _(no equivalent)_ | — | `coredns.cache.prefetch` | int |
| _(no equivalent)_ | — | `coredns.cache.serveStale` | bool |
| `configmap.log` | multiline string | `coredns.log` | list of strings |
| `loadbalancePolicy` | string | `coredns.loadbalance` | string |
| `configmap.forward` | multiline string | `coredns.public.upstreams` | list of strings |
| `configmap.forwardOptions` | string | `coredns.public.options` | string |
| `configmap.autopath` | string | `coredns.public.autopath` | string |
| `configmap.custom` | string | `coredns.custom` | string |
| `additionalLocalZones` | list | `coredns.additionalLocalZones` | list |
| `cluster.kubernetes.clusterDomain` | space-sep string | `coredns.cluster.domains` | list of strings |
| `cluster.kubernetes.API.clusterIPRange` | string | `coredns.cluster.serviceCIDR` | string |
| `cluster.calico.CIDR` | string | `coredns.cluster.podCIDR` | string |
| `cluster.kubernetes.DNS.IP` | string | `service.clusterIP` | string |
| `userID` | int | `securityContext.runAsUser` | int |
| `groupID` | int | `securityContext.runAsGroup` | int |
| `ports.prometheus` | int | `ports.metrics.port` | int |
| `mastersInstance` | object | `controlPlane` | object |

---

## Backward Compatibility

### Non-boolean values

New keys have no defaults set in `values.yaml` — they are nil when unset. Templates use `coalesce` to prefer the new path and fall through to the old path when the new key is nil:

```yaml
# Example — resolves to old path when coredns.loadbalance is unset:
{{- $loadbalance := coalesce .Values.coredns.loadbalance .Values.loadbalancePolicy | default "round_robin" }}
```

Full coalesce map used in templates:

| Value | Template expression |
|---|---|
| `cache.successTTL` | `coalesce .Values.coredns.cache.successTTL .Values.configmap.cache \| default 30` |
| `log` (list) | `if not .Values.coredns.log` → fall back to `splitList "\n" .Values.configmap.log` |
| `loadbalance` | `coalesce .Values.coredns.loadbalance .Values.loadbalancePolicy \| default "round_robin"` |
| `public.upstreams` | `if .Values.coredns.public.upstreams` → else fall back to `configmap.forward` string |
| `public.options` | `coalesce .Values.coredns.public.options .Values.configmap.forwardOptions` |
| `public.autopath` | `coalesce .Values.coredns.public.autopath .Values.configmap.autopath` |
| `cluster.domains` | `if not .Values.coredns.cluster.domains` → fall back to `splitList " " .Values.cluster.kubernetes.clusterDomain` |
| `cluster.serviceCIDR` | `coalesce .Values.coredns.cluster.serviceCIDR .Values.cluster.kubernetes.API.clusterIPRange` |
| `cluster.podCIDR` | `coalesce .Values.coredns.cluster.podCIDR .Values.cluster.calico.CIDR` |
| `service.clusterIP` | `coalesce .Values.service.clusterIP .Values.cluster.kubernetes.DNS.IP` |
| `ports.metrics.port` | `coalesce .Values.ports.metrics.port .Values.ports.prometheus \| default 9153` |
| `securityContext.runAsUser` | `coalesce .Values.securityContext.runAsUser .Values.userID \| default 33` |
| `securityContext.runAsGroup` | `coalesce .Values.securityContext.runAsGroup .Values.groupID \| default 33` |

### Boolean values (`controlPlane.enabled`)

`coalesce` treats `false` as empty and falls through, so it cannot safely handle boolean fallbacks. Instead the template uses `kindIs "invalid"` to detect whether `controlPlane.enabled` was explicitly set:

```yaml
{{- $controlPlaneEnabled := .Values.controlPlane.enabled }}
{{- if kindIs "invalid" $controlPlaneEnabled }}
  {{- $controlPlaneEnabled = .Values.mastersInstance.enabled }}
{{- end }}
{{- if $controlPlaneEnabled }}
```

This means `mastersInstance.enabled: false` continues to work correctly — `controlPlane.enabled` takes effect only when explicitly set.

### Parent objects

New parent keys that have all their children unset are declared as `{}` in `values.yaml` rather than omitted entirely. Omitting them would make the parent nil, causing a nil pointer panic when templates access child keys. `{}` gives an empty map, which safely returns nil for any child key access.

---

## Files Changed

| File | Changes |
|---|---|
| `values.yaml` | New keys added with no defaults; old keys kept as `# DEPRECATED` with migration notes |
| `values.schema.json` | New paths added with `description` fields; deprecated paths marked |
| `templates/configmap.yaml` | All values resolved via coalesce at top of file; cache now rendered as full block; log/domains handle list↔string conversion |
| `templates/deployment-masters.yaml` | `securityContext`, `controlPlane` (with `kindIs "invalid"`), `ports.metrics.port` |
| `templates/deployment-workers.yaml` | `securityContext`, `ports.metrics.port` |
| `templates/service.yaml` | `service.clusterIP` |
| `templates/np.yaml` | `ports.metrics.port` |

---

## Known Behavior Change

`configmap.cache: 30` was defined in the old `values.yaml` but was never referenced in the Corefile template — CoreDNS was effectively running with its built-in default of 3600s success TTL and 30s denial TTL. The new `coredns.cache` block is correctly applied, bringing the effective TTLs to 30s (success) / 5s (denial). Existing installations will see a change in cache behavior on upgrade unless `coredns.cache.successTTL` is explicitly set to a higher value.
