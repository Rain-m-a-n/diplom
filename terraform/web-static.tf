resource "kubernetes_namespace" "web" {
  metadata {
    name = "web-page"
  }
  depends_on = [
    yandex_kubernetes_cluster.kuber,
    yandex_kubernetes_node_group.k8s,
    helm_release.ingress-nginx
  ]
}

resource "helm_release" "web" {
  name        = "web-page"
  repository  = "http://opensource.byjg.com/helm/"
  chart       = "static-httpserver"
  version     = "0.1.0"
  namespace   = "web-page"

  values      = ["${file("./values/web.yaml")}"]
  depends_on = [kubernetes_namespace.web]
}


