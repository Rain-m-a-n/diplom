resource "kubernetes_namespace" "prometheus" {
  metadata {
    name       = "kube-prometheus-stack"
  }
  depends_on = [
    yandex_kubernetes_cluster.kuber,
    yandex_kubernetes_node_group.k8s,
    helm_release.ingress-nginx

  ]
}

resource "helm_release" "kube-prometheus-stack" {
  name       = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.9.0"
  namespace  = "kube-prometheus-stack"

  values     = ["${file("./values/kube-prometheus.yaml")}"]
  depends_on = [
    kubernetes_namespace.prometheus,
    yandex_kubernetes_node_group.k8s,
    yandex_kubernetes_cluster.kuber,
    helm_release.ingress-nginx
  ]
}

