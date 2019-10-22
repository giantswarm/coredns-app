// +build k8srequired

package templates

// CoreDNSValues values required by coredns-app.
const CoreDNSValues = `e2e: true

namespace: kube-system

cluster:
  kubernetes:
    API:
      clusterIPRange: 10.96.0.0/16
    DNS:
      IP: 10.96.0.10
`
