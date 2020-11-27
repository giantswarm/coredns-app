#!/bin/bash

# Project specific: Delete built-in kube-dns + CoreDNS in this project,
# since it cannot run side-by-side with one installed by the test.
kubectl delete service kube-dns -n kube-system
kubectl delete deployment coredns -n kube-system
kubectl delete configmap coredns -n kube-system
kubectl delete clusterrolebinding system:coredns
kubectl delete serviceaccount coredns -n kube-system
kubectl delete clusterrole system:coredns

kubectl get pods --all-namespaces