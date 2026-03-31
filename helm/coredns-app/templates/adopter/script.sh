#!/bin/bash

docker run --rm --entrypoint /bin/sh gsoci.azurecr.io/giantswarm/docker-kubectl:1.34.4 -c '
          set -e

          patchResource() {
            if kubectl get $@ >/dev/null 2>&1; then
              echo "Patching resource ${1}"
            else
              echo "resource ${1} doesn exist!"
            fi
          }

          echo "Patching existing coredns resources..."
          patchResource netpol/coredns -n kube-system
          patchResource configmap/coredns -n kube-system
          patchResource pdb/coredns -n kube-system
          patchResource serviceaccount/coredns -n kube-system
          patchResource service/kube-dns -n kube-system
          patchResource deployment/coredns -n kube-system
          patchResource clusterrole/system:coredns
          patchResource clusterrolebinding/system:coredns
          echo "Finished patching"

          # Change port specified in Corefile config

          echo "Updating coredns service..."
          echo "Finished updating coredns service"

          echo "Updating coredns deployment..."
          echo "Finished updating coredns deployment"

          echo "CoreDNS adoption complete!"

'
