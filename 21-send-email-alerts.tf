resource "aws_sns_topic_subscription" "email" {
  count = "${var.prometheus == "yes" ? 1 : 0}" 
  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = "admin@assocyate.com"
}