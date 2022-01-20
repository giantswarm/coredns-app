# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project's packages adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/giantswarm/coredns-app/compare/v1.7.0...HEAD
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
