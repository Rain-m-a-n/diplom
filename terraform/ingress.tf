  resource "helm_release" "ingress-nginx" {
    name        = "ingress-nginx"
    repository  = "https://kubernetes.github.io/ingress-nginx"
    chart       = "ingress-nginx"
#    version     = "1.19"
    namespace   = "kube-system"
    depends_on = [
      yandex_kubernetes_cluster.kuber,
      yandex_kubernetes_node_group.k8s
    ]
  }