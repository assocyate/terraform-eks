data "aws_iam_policy_document" "grafana_monitor" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:monitoring:grafana"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "grafana_monitor" {
  count = "${var.prometheus == "yes" ? 1 : 0}" 
  assume_role_policy = data.aws_iam_policy_document.grafana_monitor.json
  name               = "grafana-monitor"
}

resource "aws_iam_role_policy_attachment" "grafana_monitor_query_access" {
  count = "${var.prometheus == "yes" ? 1 : 0}" 
  role       = aws_iam_role.grafana_monitor[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusQueryAccess"
}