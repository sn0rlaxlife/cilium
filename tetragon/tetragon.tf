##tetragon installation

#helm chart for our release that is needed to be installed
resource "helm_release" "tetragon" {
  chart            = "cilium/tetragon"
  namespace        = "kube-system"
  create_namespace = "true"
  name             = "tetragon"
  version          = "1.0.0"
  repository       = "https://helm.cilium.io"
  atomic           = true

}
