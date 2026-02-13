# AWS WAF Security Framework - Outputs

output "web_acl_arn" {
  description = "ARN of the WAF WebACL"
  value       = aws_wafv2_web_acl.ecommerce.arn
}

output "web_acl_id" {
  description = "ID of the WAF WebACL"
  value       = aws_wafv2_web_acl.ecommerce.id
}

output "web_acl_name" {
  description = "Name of the WAF WebACL"
  value       = aws_wafv2_web_acl.ecommerce.name
}

output "cloudwatch_alarm_arn" {
  description = "ARN of the CloudWatch alarm for high block rate"
  value       = aws_cloudwatch_metric_alarm.waf_high_blocks.arn
}
