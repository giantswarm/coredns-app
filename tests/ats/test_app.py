from pytest import mark
from pytest_helm_charts.clusters import Cluster
from pytest_helm_charts.giantswarm_app_platform.app import wait_for_apps_to_run
from pytest_helm_charts.k8s.deployment import wait_for_deployments_to_run

@mark.smoke
@mark.functional
@mark.upgrade
def test_coredns(kube_cluster: Cluster) -> None:
    assert kube_cluster.kube_client is not None

    # Wait for coredns app to run.
    wait_for_apps_to_run(kube_cluster.kube_client, [ "coredns-app" ], "kube-system", 60)

    # Wait for coredns-controlplane & coredns-workers deployments to run.
    wait_for_deployments_to_run(kube_cluster.kube_client, [ "coredns-test-controlplane", "coredns-test-workers" ], "kube-system", 60)
