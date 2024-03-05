resource "aws_prometheus_rule_group_namespace" "monitor" {
  count = "${var.prometheus == "yes" ? 1 : 0}" 
  name         = "rules"
  workspace_id = aws_prometheus_workspace.monitor[0].id

  data = <<EOF
groups:
- name: Tutorial
  rules:
  - alert: HostHighCpuLoad
    expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100) > 60
    for: 0m
    labels:
      severity: warning
    annotations:
      summary: Host high CPU load (instance {{ $labels.instance }})
      description: "CPU load is > 60%, VALUE = {{ $value }}"
EOF
}