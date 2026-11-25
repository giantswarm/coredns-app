# Values Interface Refactor

This document describes the restructured values interface introduced in this chart. It is now the sole values interface; the previous keys have been removed. Use the Migration Map below to move existing overrides to the new paths.

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

Introduce a new top-level key **`.Values.coredns`** that holds all CoreDNS Corefile configuration in a zone-aware structure. This replaces the previously scattered keys, which have been removed. Overrides on the old paths no longer take effect and must be migrated to the new paths.

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
      success: {capacity: 9984, ttl: 30}
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
    domains:             # list of local domains, at least one required
      - cluster.local
    serviceCIDR: 172.31.0.0/16   # k8s service IP range
    podCIDR: 192.168.0.0/16      # pod network CIDR
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
| `configmap.cache` | int | `coredns.public.cache.success.ttl` / `coredns.cluster.cache.success.ttl` | int |
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

## Removed keys

Since 2.0.0 the old paths in the migration map below are gone. The values schema is strict, so setting any of them fails the install with `additional properties '<key>' not allowed` instead of being silently ignored. The one exception is `cluster.*`: the app platform injects it into every App, so the schema keeps it open and the chart ignores it.

## Parent objects

Parent keys whose children are all optional are declared as `{}` in `values.yaml` rather than omitted entirely. Omitting them would make the parent nil, causing a nil pointer panic when templates access child keys. `{}` gives an empty map, which safely returns nil for any child key access. The render helpers additionally guard every map they touch with `| default dict`, so a zone (e.g. an `additionalZones` entry) that omits `cache`, `forward`, or `kubernetes` renders safely.

---

## Files Changed

| File | Changes |
|---|---|
| `values.yaml` | Canonical keys carry the defaults; the deprecated legacy keys were removed |
| `values.schema.json` | Zone shapes (`cache`/`forward`/`kubernetes`/`log`/`loadbalance`) defined for public/cluster/additionalZones; `additionalLocalZones` (strings) replaced by `additionalZones` (objects); deprecated paths removed |
| `templates/configmap.yaml` | Builds a canonical `$zone` dict per server block (public, each cluster domain, each additionalZones entry) and renders via the helpers; generic `additionalZones` loop |
| `templates/_helpers.tpl` | `coredns.cacheBlock`, `coredns.forwardBlock`, `coredns.kubernetesBlock`, `coredns.logBlock`, `coredns.loadbalanceBlock` share the uniform signature `(dict "zone" $zone)`; each reads its slice of the zone (`cache`/`forward`/`kubernetes`/`log`/`loadbalance`, plus `names`/`cidrs`), falling back to built-in defaults |
| `templates/deployment-masters.yaml` | `securityContext`, `controlPlane`, `ports.metrics.port` |
| `templates/deployment-workers.yaml` | `securityContext`, `ports.metrics.port` |
| `templates/service.yaml` | `service.clusterIP` |
| `templates/np.yaml` | `ports.metrics.port` |

---

## Known Behavior Change

`configmap.cache: 30` was defined in the old `values.yaml` but was never referenced in the Corefile template, so CoreDNS was effectively running with its built-in default of 3600s success TTL and 30s denial TTL. The per-zone `coredns.<zone>.cache` blocks are now correctly applied, bringing the effective TTLs to 30s (success) / 5s (denial). Existing installations will see a change in cache behavior on upgrade unless a higher `coredns.public.cache.success.ttl` / `coredns.cluster.cache.success.ttl` is set.

The `health` plugin is process-wide and may be enabled in only one Server Block, so it is now rendered solely in the `.` (public) block instead of every zone block. The `ready` plugin is kept in every block because its readiness is aggregated across all blocks that enable it, per the [ready plugin docs](https://coredns.io/plugins/ready/).
