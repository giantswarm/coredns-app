// +build k8srequired

package templates

// CoreDNSValues values required by coredns-app.
const CoreDNSValues = `namespace: default

name: coredns-test

cluster:
  kubernetes:
    API:
      clusterIPRange: 10.96.0.0/16
    DNS:
      IP: 10.96.0.10
`
