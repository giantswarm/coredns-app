from typing import cast

import pytest
import pykube
from pytest_helm_charts.fixtures import Cluster


@pytest.mark.smoke
def test_we_have_environment(kube_cluster: Cluster) -> None:
    assert kube_cluster.kube_client is not None
    assert len(pykube.Node.objects(kube_cluster.kube_client)) >= 1


@pytest.mark.functional
def test_hello_working(kube_cluster: Cluster) -> None:
    srv = cast(
        pykube.Service, pykube.Service.objects(kube_cluster.kube_client).get_or_none(name="coredns-app")
    )

    print (srv)
    if srv is None:
        raise ValueError("'coredns-app service not found in the 'kube-system' namespace")
    
    page_res = srv.proxy_http_get("/")
    assert page_res.ok
    assert page_res.text == "<h1>Hello World!</h1>"
