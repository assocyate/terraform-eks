data "aws_iam_policy_document" "karpenter_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "karpenter_controller" {
  count              = "${var.scale == "karpenter" ? 1 : 0}"
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role_policy.json
  name               = "karpenter-controller"
}

resource "aws_iam_policy" "karpenter_controller" {
  count  = "${var.scale == "karpenter" ? 1 : 0}"
  policy = file("./controller-trust-policy.json")
  name   = "KarpenterController"
}

resource "aws_iam_role_policy_attachment" "aws_karpanter_controller_attach" {
  count      = "${var.scale == "karpenter" ? 1 : 0}"
  role       = aws_iam_role.karpenter_controller[0].name
  policy_arn = aws_iam_policy.karpenter_controller[0].arn
}

resource "aws_iam_instance_profile" "karpenter" {
  count = "${var.scale == "karpenter" ? 1 : 0}"
  name  = "KarpenterNodeInstanceProfile"
  role  = aws_iam_role.nodes.name
}

data "kubectl_path_documents" "provisioner_manifests" {
  pattern = "./provisioner/provisioner.yaml"
  vars = {
    cluster_name = var.cluster_name
  }
}

resource "kubectl_manifest" "provisioners" {
  count = "${var.scale == "karpenter" ? 1 : 0}"
  for_each  = data.kubectl_path_documents.provisioner_manifests.manifests
  yaml_body = each.value

  depends_on = [
  helm_release.karpenter
  ]
}
