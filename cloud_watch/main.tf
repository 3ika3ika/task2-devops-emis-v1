resource "aws_cloudwatch_metric_alarm" "cpu_usage" {
  alarm_name          = "HighCPUUsage"
  alarm_description   = "Triggered when CPU usage exceeds 70% for 5 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300  # 5 minutes (in seconds)
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    InstanceId = var.instance_id
  }

  alarm_actions = [
    aws_sns_topic.cpu_alarm_notification.arn
  ]
}

# Create an SNS topic for email notifications
resource "aws_sns_topic" "cpu_alarm_notification" {
  name = "cpu-alarm-notification"
}

# Create an SNS subscription (email)
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cpu_alarm_notification.arn
  protocol  = "email"
  endpoint  = "tomovjivko97@gmail.com"  # Replace with your email address
}
