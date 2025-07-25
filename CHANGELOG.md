# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project's packages adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Updated E2E tests to use apptest-framework v1.14.0

## [1.26.0] - 2025-06-24

### Changed

- Update `coredns` image to [1.12.2](https://github.com/coredns/coredns/releases/tag/v1.12.2).

## [1.25.0] - 2025-04-02

### Changed

- Update `coredns` image to [1.12.1](https://github.com/coredns/coredns/releases/tag/v1.12.1).

## [1.24.0] - 2025-01-28

### Changed

- Update `coredns` image to [1.12.0](https://github.com/coredns/coredns/releases/tag/v1.12.0).
- Disable HPA Memory target.
- Increase threshold for HPA CPU target to 80%.

## [1.23.0] - 2024-11-14

### Changed

- Update `coredns` image to [1.11.4](https://github.com/coredns/coredns/releases/tag/v1.11.4).
- Explicitly expose liveness and readiness probe ports in deployments.

### Removed

- Remove PodSecurityPolicy and associated Resources and values.

## [1.22.0] - 2024-09-10

### Changed

- Update `coredns` image to [1.11.3](https://github.com/coredns/coredns/releases/tag/v1.11.3).

### Removed

- Removed legacy Giant Swarm monitoring labels as coredns is monitored through a prometheus-operator generated servicemonitor.

## [1.21.0] - 2024-01-09

### Changed

- Configure `gsoci.azurecr.io` as the default container image registry.

## [1.20.0] - 2023-12-06

### Added

- Add NET_BIND_SERVICE capability back to containers.

### Changed

- Upgrade CoreDNS to [v1.11.1](https://github.com/coredns/coredns/releases/tag/v1.11.1).

## [1.19.1] - 2023-11-20

### Changed

- Build App with ABS.
- Add basic tests with ATS.
- ATS: Rework tests. ([#248](https://github.com/giantswarm/coredns-app/pull/248))
- Chart: Fix usage of `name` & `namespace`. ([#249](https://github.com/giantswarm/coredns-app/pull/249))

## [1.19.0] - 2023-09-28

### Changed

- Make App compliant with PSS policies ([#234](https://github.com/giantswarm/coredns-app/pull/234)):
  - Set seccompProfile to `RuntimeDefault`.
  - Fix capabilities typo.
  - Remove `NET_BIND_SERVICE` capabilities.
  - Set `runAsNonRoot` as true.

## [1.18.1] - 2023-08-30

### Fixed

- Remove `fallthrough` for reverse zones from kubernetes plugin.

## [1.18.0] - 2023-08-01

### Added

- Add a new field `additionalLocalZones` which can be used to introduce more internal local zones, e.g. linkerd.

### Changed

- Create a `coredns` zone for each cluster domain.
- Adjust the settings for upscaling HPA when hitting 60% CPU.
- Adjust the settings for downscaling HPA to 30 minutes.
- Adjust the min and max memory settings per Pod.
- Enable cache inconditionaly for `.` and local zones.
- Adjust the settings for upscaling HPA when hitting 80% Memory.

## [1.17.1] - 2023-07-13

### Changed

- Disable IPV6 queries.

## [1.17.0] - 2023-05-12

### Added

- Add scaling based on custom metrics ([#209](https://github.com/giantswarm/coredns-app/pull/209)).

### Changed

- Decouple PDB configuration from deployment updateStrategy ([#208](https://github.com/giantswarm/coredns-app/pull/208)).

## [1.16.0] - 2023-05-04

### Changed

- Disable PSPs for k8s 1.25 and newer.
- Switch to `apiVersion: policy/v1` for PodDisruptionBudget.

## [1.15.2] - 2023-04-06

### Changed

- Add `http-metrics` port to the list of exposed ports so Prometheus can access container metadata (e.g. `__meta_kubernetes_pod_container_xxx`).

## [1.15.1] - 2023-04-05

### Fixed

- Fix controlplane label in Kubernetes 1.24.

## [1.15.0] - 2023-03-30

### Added

- Add HPA by Memory usage.

### Changed

- Migrate to autoscaling/v2beta2 API version.
- Detect HPA API version based on capabilities.

## [1.14.3] - 2023-03-23

### Changed

- Use `node-role.kubernetes.io/control-plane` as key for node selector for master instances as `node-role.kubernetes.io/master` is deprecated and removed in v1.25

## [1.14.2] - 2023-02-15

### Changed

- ConfigMap: Add lameduck of 5 seconds to health check ([#191](https://github.com/giantswarm/coredns-app/pull/191)).

## [1.14.1] - 2023-02-14

### Removed

- Deployment: Drop static `replicas`, managed by HPA. ([#188](https://github.com/giantswarm/coredns-app/pull/188))

## [1.14.0] - 2023-02-13

### Changed

- Change PodDisruptionBudget to move from `maxUnavailable: 1` to `maxUnavailable: 25%` for better scaling

## [1.13.0] - 2022-12-28

### Added

- `values.schema.json` file

### Changed

- Move nodeselector `label:value` to values.yaml to allow customizing it for CAPZ
- Add toleration for `node-role.kubernetes.io/control-plane` to masters instance

## [1.12.0] - 2022-11-30

### Added

- Possibility to set scale down `stabilizationWindowSeconds` behaviour

## [1.11.0] - 2022-07-12

### Changed

- Update `coredns` to upstream version [1.9.3](https://coredns.io/2022/05/27/coredns-1.9.3-release/).

## [1.10.1] - 2022-06-17

### Fixed

- Added component label to deployment labels as well

## [1.10.0] - 2022-06-17

### Added

- Add `app.kubernetes.io/component` on deployments so that management-cluster-admission controller does not complain.

## [1.9.1] - 2022-06-16

### Fixed

- Correct pod selectors on each deployment. Deployments renamed to allow for changing the selectors.

## [1.9.0] - 2022-04-11

### Added

- Add toleration for `node.cloudprovider.kubernetes.io/uninitialized`.

### Changed

- Update `coredns` to upstream version [1.8.7](https://coredns.io/2021/12/09/coredns-1.8.7-release/).

## [1.8.0] - 2022-01-20

### Changed

- Add deployment to run one replica of coredns in master nodes (for clusters with no node pools).

## [1.7.0] - 2022-01-04

### Changed

- Update `coredns` to upstream version [1.8.6](https://coredns.io/2021/10/07/coredns-1.8.6-release/).

## [1.6.0] - 2021-06-14

- Make `targetCPUUtilizationPercentage` in HPA configurable.

## [1.5.0] - 2021-06-10

### Changed

- Update `coredns` to upstream version [1.8.3](https://coredns.io/2021/02/24/coredns-1.8.3-release/).
- Increase maximum replica count to 50 when using horizontal pod autoscaling.

## [1.4.1] - 2021-03-26

### Changed

- Set docker.io as the default registry

## [1.4.0] - 2021-02-10

### Changed

- Update `coredns` to upstream version [1.8.0](https://coredns.io/2020/10/22/coredns-1.8.0-release/).

## [1.3.0] - 2021-02-09

### Changed

- Update `coredns` to upstream version [1.7.1](https://coredns.io/2020/09/21/coredns-1.7.1-release/) (including changes introduced in version [1.7.0](https://coredns.io/2020/06/15/coredns-1.7.0-release/)).

## [1.2.1] - 2021-02-05

### Added

- Added monitoring annotations and common labels.

### Changed

- Update `coredns` to upstream version [1.6.9](https://coredns.io/2020/03/24/coredns-1.6.9-release/).

## [v1.2.0] 2020-07-13

### Changed

- Apply a readiness probe
- Increase the liveness probe failure threshold from 5 failures to 7 failures

## [v1.1.10] 2020-06-29

### Changed

- Make resource requests/limits configurable.
- Applying Go modules.

## [v1.1.9] 2020-05-04

### Changed

- Make forward options optional.

## [v1.1.8] 2020-03-20

### Changed

- Use cluster.kubernetes.clusterDomain instead of cluster.kubernetes.domain for custom DNS suffix.

## [v1.1.7] 2020-03-19

### Changed

- Set `autopath` variable to disabled by default in values file.

## [v1.1.6] 2020-02-28

### Added

- Add Pod Disruption Budget.

## [v1.1.5] 2020-02-28

### Added

- Allow custom forward configuration destination and options.

## [v1.1.4] 2020-02-27

### Added

- Add `autopath` variable in the values file to make possible to configure or disable the plugin.

## [v1.1.3] 2020-01-08

### Changed

- Fix HPA manifests for Kubernetes 1.16.

## [v1.1.2] 2020-01-03

### Changed

- Updated manifests for Kubernetes 1.16.

## [v1.1.1]

### Changed

- Removed CPU limits.

## [v1.1.0]

### Changed

- Updated coredns to upstream version [1.6.5](https://coredns.io/2019/11/05/coredns-1.6.5-release/).

## [v1.0.0]

### Changed

- Migrated to be deployed via an app CR not a chartconfig CR.

## [v0.8.0]

### Added

- Change CoreDNS version to `1.6.4` with different enhancements and fixes.
  - [1.6.3 release notes](https://coredns.io/2019/08/31/coredns-1.6.3-release/).
  - [1.6.4 release notes](https://coredns.io/2019/09/27/coredns-1.6.4-release/).

## [v0.7.0]

### Added

- Change CoreDNS version to `1.6.2` with different enhancements and fixes.
  - [1.6.0 release notes](https://coredns.io/2019/07/28/coredns-1.6.0-release/).
  - [1.6.1 release notes](https://coredns.io/2019/08/02/coredns-1.6.1-release/).
  - [1.6.2 release notes](https://coredns.io/2019/08/13/coredns-1.6.2-release/).

- The deployment has included the Prometheus Operator annotations to make the target discovery easier by Prometheus.

### Changed

- Align autopath configuration according to upstream documentation, so from now on the pods parameter will be `verified`.
- Specify `-dns.port` arg explicitly with `1053` value.

## [v0.6.3]

### Changed

- Change network policy to allow all sources to access ports `53` and `1053`. This change fixes broken `ClusterFirst`  dns policies for pods.

## [v0.6.2]

### Added

- Change CoreDNS version to `1.5.1` ([release notes](https://coredns.io/2019/06/26/coredns-1.5.1-release/)). In this version [`any`](https://coredns.io/plugins/any) plugin has been added.

- Fix Forward values to keep the original order.

## [v0.6.1]

### Changed

- Fix Custom values to keep the original order.

## [v0.6.0]

### Added

- Network policy that allows access to coredns dns service from all pods.
- Network policy that allows accessing metrics on port `9153`.

## [v0.5.1]

### Added

- Make `log` plugin verbosity configurable according to [levels available](https://github.com/coredns/coredns/tree/master/plugin/log).

## [v0.5.0]

### Added

- Separate pod security policy for coredns and coredns-migration workloads.
- Security context with non-root user (`www-data`) for running coredns inside container.

### Changed

- Switched from port `53` to port `1053` for coredns inside container.

__Warning__: This change is because the default port `53` is blocked because it is a privileged port. In case you are using the custom block (`coredns-user-values`) you need to update it to specify the port `1053` like in this example.

```
data:
  custom: |
    example.com:1053 {
      forward . 9.9.9.9
      cache 2000
    }
```

## [v0.4.1]

### Changed

- Auto scaling settings has been adjusted based on past experiences. Now coreDNS responds better to a request peak.

## [v0.4.0]

### Changed

- Change CoreDNS version to `1.5.0` ([release notes](https://coredns.io/2019/04/06/coredns-1.5.0-release/)). In this version [`grpc`](https://coredns.io/plugins/grpc) and [`ready`](https://coredns.io/plugins/ready) plugins have been added.

- Please review the [release notes](https://coredns.io/2019/03/03/coredns-1.4.0-release/) of version `1.4.0`. This version was skipped as upstream reported two bugs and they were fixed in fast next release.

- Change general server block resolvers. Now it uses `forward` plugin to route DNS request to upstreams resolvers.

### Removed

- Remove `proxy` configuration support as it is [deprecated by upstream](https://coredns.io/2019/03/03/coredns-1.4.0-release/). New server block with `forward` plugin has to be used, more info in our [docs](https://docs.giantswarm.io/guides/advanced-coredns-configuration/).

[Unreleased]: https://github.com/giantswarm/coredns-app/compare/v1.26.0...HEAD
[1.26.0]: https://github.com/giantswarm/coredns-app/compare/v1.25.0...v1.26.0
[1.25.0]: https://github.com/giantswarm/coredns-app/compare/v1.24.0...v1.25.0
[1.24.0]: https://github.com/giantswarm/coredns-app/compare/v1.23.0...v1.24.0
[1.23.0]: https://github.com/giantswarm/coredns-app/compare/v1.22.0...v1.23.0
[1.22.0]: https://github.com/giantswarm/coredns-app/compare/v1.21.0...v1.22.0
[1.21.0]: https://github.com/giantswarm/coredns-app/compare/v1.20.0...v1.21.0
[1.20.0]: https://github.com/giantswarm/coredns-app/compare/v1.19.1...v1.20.0
[1.19.1]: https://github.com/giantswarm/coredns-app/compare/v1.19.0...v1.19.1
[1.19.0]: https://github.com/giantswarm/coredns-app/compare/v1.18.1...v1.19.0
[1.18.1]: https://github.com/giantswarm/coredns-app/compare/v1.18.0...v1.18.1
[1.18.0]: https://github.com/giantswarm/coredns-app/compare/v1.17.1...v1.18.0
[1.17.1]: https://github.com/giantswarm/coredns-app/compare/v1.17.0...v1.17.1
[1.17.0]: https://github.com/giantswarm/coredns-app/compare/v1.16.0...v1.17.0
[1.16.0]: https://github.com/giantswarm/coredns-app/compare/v1.15.2...v1.16.0
[1.15.2]: https://github.com/giantswarm/coredns-app/compare/v1.15.1...v1.15.2
[1.15.1]: https://github.com/giantswarm/coredns-app/compare/v1.15.0...v1.15.1
[1.15.0]: https://github.com/giantswarm/coredns-app/compare/v1.14.3...v1.15.0
[1.14.3]: https://github.com/giantswarm/coredns-app/compare/v1.14.2...v1.14.3
[1.14.2]: https://github.com/giantswarm/coredns-app/compare/v1.14.1...v1.14.2
[1.14.1]: https://github.com/giantswarm/coredns-app/compare/v1.14.0...v1.14.1
[1.14.0]: https://github.com/giantswarm/coredns-app/compare/v1.13.0...v1.14.0
[1.13.0]: https://github.com/giantswarm/coredns-app/compare/v1.12.0...v1.13.0
[1.12.0]: https://github.com/giantswarm/coredns-app/compare/v1.11.0...v1.12.0
[1.11.0]: https://github.com/giantswarm/coredns-app/compare/v1.10.1...v1.11.0
[1.10.1]: https://github.com/giantswarm/coredns-app/compare/v1.10.0...v1.10.1
[1.10.0]: https://github.com/giantswarm/coredns-app/compare/v1.9.1...v1.10.0
[1.9.1]: https://github.com/giantswarm/coredns-app/compare/v1.9.0...v1.9.1
[1.9.0]: https://github.com/giantswarm/coredns-app/compare/v1.8.0...v1.9.0
[1.8.0]: https://github.com/giantswarm/coredns-app/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/giantswarm/coredns-app/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/giantswarm/coredns-app/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/giantswarm/coredns-app/compare/v1.4.1...v1.5.0
[1.4.1]: https://github.com/giantswarm/coredns-app/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/giantswarm/coredns-app/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/giantswarm/coredns-app/compare/v1.2.1...v1.3.0
[1.2.1]: https://github.com/giantswarm/coredns-app/compare/v1.2.0...v1.2.1
[v1.2.0]: https://github.com/giantswarm/coredns-app/compare/v1.1.10...v1.2.0
[v1.1.10]: https://github.com/giantswarm/coredns-app/compare/v1.1.9...v1.1.10
[v1.1.9]: https://github.com/giantswarm/coredns-app/compare/v1.1.8...v1.1.9
[v1.1.8]: https://github.com/giantswarm/coredns-app/compare/v1.1.7...v1.1.8
[v1.1.7]: https://github.com/giantswarm/coredns-app/compare/v1.1.6...v1.1.7
[v1.1.6]: https://github.com/giantswarm/coredns-app/compare/v1.1.5...v1.1.6
[v1.1.5]: https://github.com/giantswarm/coredns-app/compare/v1.1.4...v1.1.5
[v1.1.4]: https://github.com/giantswarm/coredns-app/compare/v1.1.3...v1.1.4
[v1.1.3]: https://github.com/giantswarm/coredns-app/compare/v1.1.2...v1.1.3
[v1.1.3]: https://github.com/giantswarm/coredns-app/compare/v1.1.2...v1.1.3
[v1.1.2]: https://github.com/giantswarm/coredns-app/compare/v1.1.1...v1.1.2
[v1.1.1]: https://github.com/giantswarm/coredns-app/compare/v1.1.0...v1.1.1
[v1.1.0]: https://github.com/giantswarm/coredns-app/compare/v1.0.0...v1.1.0
[v1.0.0]: https://github.com/giantswarm/coredns-app/pull/6
[v0.8.0]: https://github.com/giantswarm/kubernetes-coredns/pull/49
[v0.7.0]: https://github.com/giantswarm/kubernetes-coredns/pull/46
[v0.6.2]: https://github.com/giantswarm/kubernetes-coredns/pull/36
[v0.6.1]: https://github.com/giantswarm/kubernetes-coredns/pull/32
[v0.5.1]: https://github.com/giantswarm/kubernetes-coredns/pull/32
[v0.5.0]: https://github.com/giantswarm/kubernetes-coredns/pull/28
[v0.4.0]: https://github.com/giantswarm/kubernetes-coredns/pull/27
