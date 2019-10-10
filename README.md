[![CircleCI](https://circleci.com/gh/giantswarm/coredns-app.svg?style=shield)](https://circleci.com/gh/giantswarm/coredns-app)

# coredns-app
Helm Chart for CoreDNS in Tenant Clusters.

* Installs the the DNS server [CoreDNS](https://github.com/coredns/coredns).

## Deployment 

* Managed by [app-operator].
* Production releases are stored in the [default-catalog].
* WIP releases are stored in the [default-test-catalog].

## Installing the Chart

To install the chart locally:

```bash
$ git clone https://github.com/giantswarm/coredns-app.git
$ cd coredns-app
$ helm install helm/coredns-app
```

Provide a custom `values.yaml`:

```bash
$ helm install coredns-app -f values.yaml
```

## Release Process

* Ensure CHANGELOG.md is up to date.
* Create a new GitHub release with the version e.g. `v0.1.0` and link the
changelog entry.
* This will push a new git tag and trigger a new tarball to be pushed to the
[default-catalog].  
* Update [cluster-operator] with the new version.