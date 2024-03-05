  provider "kubernetes" {
    host                   = aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.cluster.id]
      command     = "aws"
    }
  }

resource "kubernetes_namespace" "deploy-ns" {
  metadata {
    name = "${var.namespace}"
  }

  depends_on = [
    aws_eks_node_group.private-nodes
  ]
}

resource "kubernetes_horizontal_pod_autoscaler" "hpa" {
  count = "${var.scale == "autoscale" ? 1 : 0}"
  metadata {
    name = "${var.release_name}"
    namespace = "${var.namespace}"
  }

  spec {
    max_replicas = 10
    min_replicas = 1
    target_cpu_utilization_percentage = 50

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "${var.release_name}"
    }
  }

  depends_on = [
    aws_eks_node_group.private-nodes,
    aws_iam_role_policy_attachment.eks_cluster_autoscaler_attach,
    kubernetes_horizontal_pod_autoscaler.hpa
  ]

}