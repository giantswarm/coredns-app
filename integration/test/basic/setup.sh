#!/bin/bash

# Project specific: Delete built-in kube-dns + CoreDNS in this project,
# since it cannot run side-by-side with one installed by the test.
kubectl delete service kube-dns -n kube-system
kubectl delete deployment coredns -n kube-system
kubectl delete configmap coredns -n kube-system
kubectl delete clusterrolebinding system:coredns
kubectl delete serviceaccount coredns -n kube-system
kubectl delete clusterrole system:coredns

# For app-operator to find the catalog file we need to enable some form of dns
kubectl patch deployment -n giantswarm chart-operator-unique --patch "$(cat ./integration/test/basic/dns-patch.yaml)"
kubectl patch deployment -n giantswarm app-operator-unique --patch "$(cat ./integration/test/basic/dns-patch.yaml)"

