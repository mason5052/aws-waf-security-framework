# AWS WAF Security Framework - Variables

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "ecommerce"
}

variable "aws_region" {
  description = "AWS region for WAF deployment"
  type        = string
  default     = "us-east-1"
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer to protect"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of SNS topic for alarm notifications"
  type        = string
}

variable "global_rate_limit" {
  description = "Maximum requests per 5-minute window per IP (global)"
  type        = number
  default     = 2000
}

variable "api_rate_limit" {
  description = "Maximum API requests per 5-minute window per IP"
  type        = number
  default     = 100
}

variable "blocked_countries" {
  description = "List of country codes to block (ISO 3166-1 alpha-2)"
  type        = list(string)
  default     = []
}

variable "block_alarm_threshold" {
  description = "Number of blocked requests in 5min to trigger alarm"
  type        = number
  default     = 1000
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "ecommerce-waf"
    ManagedBy = "terraform"
  }
}
