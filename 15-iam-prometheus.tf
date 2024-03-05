data "aws_iam_policy_document" "prometheus_monitor" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:monitoring:prometheus"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "prometheus_monitor" {
  count = "${var.prometheus == "yes" ? 1 : 0}"     
  assume_role_policy = data.aws_iam_policy_document.prometheus_monitor.json
  name               = "prometheus-monitor"
}

resource "aws_iam_policy" "prometheus_monitor_ingest_access" {
  count = "${var.prometheus == "yes" ? 1 : 0}"  
  name = "PrometheusmonitorIngestAccess"

  policy = jsonencode({
    Statement = [{
      Action = [
        "aps:RemoteWrite"
      ]
      Effect   = "Allow"
      Resource = aws_prometheus_workspace.monitor[*].arn
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "prometheus_monitor_ingest_access" {
  count = "${var.prometheus == "yes" ? 1 : 0}" 
  role       = aws_iam_role.prometheus_monitor[0].name
  policy_arn = aws_iam_policy.prometheus_monitor_ingest_access[0].arn
}

resource "aws_iam_instance_profile" "prometheus_monitor" {
  count = "${var.prometheus == "yes" ? 1 : 0}" 
  name = "prometheus-monitor"
  role = aws_iam_role.prometheus_monitor[0].name
}

# OPTIONAL: only if you have standalone EC2 instances to scrape
resource "aws_iam_role_policy_attachment" "prometheus_ec2_access" {
  count = "${var.prometheus == "yes" ? 1 : 0}" 
  role       = aws_iam_role.prometheus_monitor[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}