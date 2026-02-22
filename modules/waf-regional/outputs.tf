# ============================================================================
# AWS WAF Regional Module - Outputs
# Author: Mason Kim (https://github.com/mason5052)
# ============================================================================

output "web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.id
}

output "web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "web_acl_name" {
  description = "The name of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.name
}

output "web_acl_capacity" {
  description = "The capacity units used by the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.capacity
}

output "ip_set_whitelist_arn" {
  description = "The ARN of the IP whitelist set (if created)"
  value       = length(var.ip_whitelist) > 0 ? aws_wafv2_ip_set.whitelist[0].arn : null
}

output "ip_set_whitelist_id" {
  description = "The ID of the IP whitelist set (if created)"
  value       = length(var.ip_whitelist) > 0 ? aws_wafv2_ip_set.whitelist[0].id : null
}
