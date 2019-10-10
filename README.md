[![CircleCI](https://circleci.com/gh/giantswarm/coredns-app.svg?style=shield)](https://circleci.com/gh/giantswarm/coredns-app)

# coredns-app
Helm Chart for CoreDNS in Guest Clusters.

* Installs the the DNS server [CoreDNS](https://github.com/coredns/coredns).

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

Deployment to Guest Clusters will be handled by [chart-operator](https://github.com/giantswarm/chart-operator).
