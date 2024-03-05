resource "aws_cloudwatch_log_group" "prometheus_monitor" {
  count = "${var.prometheus == "yes" ? 1 : 0}" 
  name              = "/aws/prometheus/monitor"
  retention_in_days = 14
}

resource "aws_prometheus_workspace" "monitor" {
  count = "${var.prometheus == "yes" ? 1 : 0}" 
  alias = "monitor"

  logging_configuration {
    log_group_arn = "${aws_cloudwatch_log_group.prometheus_monitor[0].arn}:*"
  }
}
/*
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}*/ 