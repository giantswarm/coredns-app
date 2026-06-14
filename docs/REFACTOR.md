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

Cache, log, and loadbalance are configured **per zone** (no global block); each zone
(public, cluster, and every `additionalZones` entry) carries its own optional `cache`,
`log`, and `loadbalance`, falling back to built-in defaults when omitted (cache:
`success 9984 30` / `denial 9984 5`; log: `denial`+`error`; loadbalance: `round_robin`).

```yaml
coredns:
  # "." zone — external/public DNS (forward zone)
  public:
    cache:                 # per-zone cache (omit -> defaults)
      success: {capacity: 9984, ttl: 30}   # ttl defaults to configmap.cache for backward compat
      denial:  {capacity: 9984, ttl: 5}
      # prefetch / serveStale / servfail / disable / keepttl / ttl ...
    forward:               # structured forward directive (mirrors the CoreDNS forward block); FROM is always "."
      to: []               # upstream DNS servers (forward "TO..." targets); empty = /etc/resolv.conf
      # policy / forceTCP / preferUDP / maxFails / healthCheck / expire / except ...
    log:                   # per-zone log classes (omit -> denial+error)
      - denial
      - error
    loadbalance: round_robin   # round_robin | random (omit -> round_robin)
    autopath: ""         # autopath plugin args (optional)

  # cluster.local zone — in-cluster DNS (kubernetes plugin)
  cluster:
    domains:             # list of local domains — defaults to cluster.kubernetes.clusterDomain
      - cluster.local
    serviceCIDR: 172.31.0.0/16   # k8s service IP range — defaults to cluster.kubernetes.API.clusterIPRange
    podCIDR: 192.168.0.0/16      # pod network CIDR — defaults to cluster.calico.CIDR
    cache: {success: {...}, denial: {...}}   # per-zone cache
    kubernetes:          # structured kubernetes-plugin params (mirrors the CoreDNS kubernetes block)
      pods: verified       # disabled | insecure | verified
      # ttl / endpointPodNames / noendpoints / namespaces / labels / ignoreEmptyService / fallthrough ...
    log: [denial, error]       # per-zone log classes
    loadbalance: round_robin   # per-zone loadbalance policy

  # extra zones — each a fully-templated server block
  additionalZones: []
  # - names: [linkerd.local]       # zone names served by the block (required)
  #   cidrs: [10.96.0.0/12]        # optional reverse (PTR) ranges
  #   cache: {success: {ttl: 15}}  # optional per-zone cache
  #   kubernetes: {pods: verified} # forward and/or kubernetes (or neither)
  #   log: [denial]                # optional per-zone log classes
  #   loadbalance: random          # optional per-zone loadbalance policy
  # - names: [upstream.example.com]
  #   forward: {to: [10.0.0.53]}

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
| `configmap.cache` (was unused in template) | int | `coredns.public.cache.success.ttl` / `coredns.cluster.cache.success.ttl` | int |
| _(no equivalent)_ | — | `coredns.<zone>.cache.success.{capacity,minTTL}` | int |
| _(no equivalent)_ | — | `coredns.<zone>.cache.denial.{ttl,capacity,minTTL}` | int |
| _(no equivalent)_ | — | `coredns.<zone>.cache.prefetch.{amount,duration,percentage}` | mixed |
| _(no equivalent)_ | — | `coredns.<zone>.cache.serveStale.{enabled,duration,refreshMode}` | mixed |
| _(no equivalent)_ | — | `coredns.<zone>.cache.{servfail.duration,disable.*,keepttl,ttl}` | mixed |
| `configmap.log` | multiline string | `coredns.<zone>.log` (per-zone) | list of strings |
| `loadbalancePolicy` | string | `coredns.<zone>.loadbalance` (per-zone) | string |
| `configmap.forward` | multiline string | `coredns.public.forward.to` | list of strings |
| `configmap.forwardOptions` | string | `coredns.public.forward` (params) | object (structured) |
| `configmap.autopath` | string | `coredns.public.autopath` | string |
| `configmap.custom` | string | `coredns.custom` | string |
| `additionalLocalZones` | list of strings | `coredns.additionalZones` | list of zone objects (`names`, `cidrs`, `cache`, `forward`, `kubernetes`) |
| `cluster.kubernetes.clusterDomain` | space-sep string | `coredns.cluster.domains` | list of strings |
| `cluster.kubernetes.API.clusterIPRange` | string | `coredns.cluster.serviceCIDR` | string |
| `cluster.calico.CIDR` | string | `coredns.cluster.podCIDR` | string |
| `pods verified` (was hardcoded in template) | — | `coredns.cluster.kubernetes.pods` | string |
| _(no equivalent)_ | — | `coredns.cluster.kubernetes.ttl` | int |
| _(no equivalent)_ | — | `coredns.cluster.kubernetes.endpointPodNames` | bool |
| _(no equivalent)_ | — | `coredns.cluster.kubernetes.noendpoints` | bool |
| _(no equivalent)_ | — | `coredns.cluster.kubernetes.namespaces` | list of strings |
| _(no equivalent)_ | — | `coredns.cluster.kubernetes.labels` | string |
| _(no equivalent)_ | — | `coredns.cluster.kubernetes.ignoreEmptyService` | bool |
| _(no equivalent)_ | — | `coredns.cluster.kubernetes.fallthrough` | bool |
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
# Example — resolves to the deprecated path when the per-zone loadbalance is unset:
{{- $policy := coalesce $zone.loadbalance .ctx.Values.loadbalancePolicy | default "round_robin" }}
```

Full coalesce map used in templates:

| Value | Template expression |
|---|---|
| `<zone>.cache.success.ttl` | per zone, inside `coredns.cacheBlock`: `coalesce $success.ttl .ctx.Values.configmap.cache \| default 30` |
| `<zone>.log` (list) | per zone, inside `coredns.logBlock`: `$zone.log` → else `splitList "\n" .ctx.Values.configmap.log` → else `denial`+`error` |
| `<zone>.loadbalance` | per zone, inside `coredns.loadbalanceBlock`: `coalesce $zone.loadbalance .ctx.Values.loadbalancePolicy \| default "round_robin"` |
| `public.forward.to` | `if .Values.coredns.public.forward.to` → else fall back to `configmap.forward` string (only the public zone passes `legacy: true`) |
| `public.forward` (params) | rendered by the `coredns.forwardBlock` helper; falls back to the raw `configmap.forwardOptions` string when no structured params are set |
| `public.autopath` | `coalesce .Values.coredns.public.autopath .Values.configmap.autopath` |
| `cluster.domains` | `if not .Values.coredns.cluster.domains` → fall back to `splitList " " .Values.cluster.kubernetes.clusterDomain` |
| `cluster.serviceCIDR` | `coalesce .Values.coredns.cluster.serviceCIDR .Values.cluster.kubernetes.API.clusterIPRange` |
| `cluster.podCIDR` | `coalesce .Values.coredns.cluster.podCIDR .Values.cluster.calico.CIDR` |
| `additionalZones` | `if .Values.coredns.additionalZones` → render objects; else fall back to deprecated `additionalLocalZones` string list (rendered as kubernetes zones with default cache) |
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

New parent keys that have all their children unset are declared as `{}` in `values.yaml` rather than omitted entirely. Omitting them would make the parent nil, causing a nil pointer panic when templates access child keys. `{}` gives an empty map, which safely returns nil for any child key access. The render helpers additionally guard every map they touch with `| default dict`, so a zone (e.g. an `additionalZones` entry) that omits `cache`, `forward`, or `kubernetes` renders safely.

---

## Files Changed

| File | Changes |
|---|---|
| `values.yaml` | New keys added with no defaults; old keys kept as `# DEPRECATED` with migration notes |
| `values.schema.json` | `cache`/`forward`/`kubernetes`/`log`/`loadbalance` extracted to `definitions` and `$ref`'d from public/cluster/additionalZones; `additionalLocalZones` (strings) replaced by `additionalZones` (objects); deprecated paths marked |
| `templates/configmap.yaml` | Builds a canonical `$zone` dict per server block (public, each cluster domain, each additionalZones entry) and renders via the helpers; generic `additionalZones` loop + legacy `additionalLocalZones` string fallback |
| `templates/_helpers.tpl` | `coredns.cacheBlock`, `coredns.forwardBlock`, `coredns.kubernetesBlock`, `coredns.logBlock`, `coredns.loadbalanceBlock` share the uniform signature `(dict "zone" $zone "ctx" $)` — each reads its slice of the zone (`cache`/`forward`/`kubernetes`/`log`/`loadbalance`, plus `names`/`cidrs`/`legacy`). Forward's `configmap.*` fallback is gated by `$zone.legacy` (public only); log/loadbalance fall back to the deprecated `configmap.log` / `loadbalancePolicy` then built-in defaults |
| `templates/deployment-masters.yaml` | `securityContext`, `controlPlane` (with `kindIs "invalid"`), `ports.metrics.port` |
| `templates/deployment-workers.yaml` | `securityContext`, `ports.metrics.port` |
| `templates/service.yaml` | `service.clusterIP` |
| `templates/np.yaml` | `ports.metrics.port` |

---

## Known Behavior Change

`configmap.cache: 30` was defined in the old `values.yaml` but was never referenced in the Corefile template — CoreDNS was effectively running with its built-in default of 3600s success TTL and 30s denial TTL. The per-zone `coredns.<zone>.cache` blocks are now correctly applied, bringing the effective TTLs to 30s (success) / 5s (denial). Existing installations will see a change in cache behavior on upgrade unless a higher `coredns.public.cache.success.ttl` / `coredns.cluster.cache.success.ttl` is set.
