import json
import logging
import os
import shutil
import subprocess  # nosec
import time
from typing import Any

import pykube
import pytest
import requests
import yaml
from pykube import HTTPClient
from pytest_helm_charts.clusters import Cluster
from pytest_helm_charts.giantswarm_app_platform.app import (
    AppCR,
    AppFactoryFunc,
    ConfiguredApp,
)
from pytest_helm_charts.k8s.deployment import wait_for_deployments_to_run
from pytest_helm_charts.k8s.daemon_set import wait_for_daemon_sets_to_run
from pytest_helm_charts.k8s.namespace import ensure_namespace_exists

logger = logging.getLogger(__name__)

timeout: int = 360

app_catalog_url = "https://giantswarm.github.io/giantswarm-catalog/"

app_namespace = "default"
app_name = "coredns-app"

def load_yaml_from_path(filepath) -> Any:
    with open(filepath, "r", encoding="utf-8") as values_file:
        values = values_file.read()

    yaml_config = yaml.safe_load(values)
    return yaml_config

@pytest.fixture(scope="module")
def coredns_app_cr(
    app_factory: AppFactoryFunc, chart_version: str
) -> ConfiguredApp:
    res = app_factory(
        app_name,
        chart_version,
        f"chartmuseum-test-time",
        app_namespace,
        "http://chartmuseum.giantswarm.svc.cluster.local.:8080/",
        timeout_sec=timeout,
        namespace=app_namespace,
        config_values=load_yaml_from_path("test-values.yaml"),
        deployment_namespace=app_namespace,
    )
    return res


@pytest.mark.smoke
def test_api_working(kube_cluster: Cluster) -> None:
    """
    Test if the kubernetes api works
    """
    assert kube_cluster.kube_client is not None
    assert len(pykube.Node.objects(kube_cluster.kube_client)) >= 1

    kube_cluster.kubectl(
        "get ns"
    )


@pytest.mark.smoke
def test_coredns_deployed(kube_cluster: Cluster, coredns_app_cr: AppCR):
    app_cr = (
        AppCR.objects(kube_cluster.kube_client)
        .filter(namespace=app_namespace)
        .get_by_name(app_name)
    )
    app_version = app_cr.obj["status"]["version"]
    wait_for_deployments_to_run(
        kube_cluster.kube_client,
        # this is the name of the deployments
        ["coredns-test-controlplane", "coredns-test-workers"],
        app_namespace,
        timeout,
    )
    logger.info(f"CoreDNS App CR shows installed appVersion {app_version}")

