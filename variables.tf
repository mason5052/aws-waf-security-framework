# AWS WAF Security Framework - Variables

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "ecommerce"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "aws_region" {
  description = "AWS region for WAF deployment"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "Must be a valid AWS region (e.g., us-east-1, eu-west-1)."
  }
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer to protect"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:elasticloadbalancing:", var.alb_arn))
    error_message = "Must be a valid ALB ARN starting with arn:aws:elasticloadbalancing:"
  }
}

variable "sns_topic_arn" {
  description = "ARN of SNS topic for alarm notifications"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:sns:", var.sns_topic_arn))
    error_message = "Must be a valid SNS topic ARN starting with arn:aws:sns:"
  }
}

variable "global_rate_limit" {
  description = "Maximum requests per 5-minute window per IP (global)"
  type        = number
  default     = 2000

  validation {
    condition     = var.global_rate_limit >= 100
    error_message = "Global rate limit must be at least 100 (AWS WAF minimum)."
  }
}

variable "api_rate_limit" {
  description = "Maximum API requests per 5-minute window per IP"
  type        = number
  default     = 100

  validation {
    condition     = var.api_rate_limit >= 100
    error_message = "API rate limit must be at least 100 (AWS WAF minimum)."
  }
}

variable "blocked_countries" {
  description = "List of country codes to block (ISO 3166-1 alpha-2)"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for c in var.blocked_countries : can(regex("^[A-Z]{2}$", c))])
    error_message = "Country codes must be 2-letter uppercase ISO 3166-1 alpha-2 codes."
  }
}

variable "block_alarm_threshold" {
  description = "Number of blocked requests in 5min to trigger alarm"
  type        = number
  default     = 1000

  validation {
    condition     = var.block_alarm_threshold > 0
    error_message = "Block alarm threshold must be a positive number."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "ecommerce-waf"
    ManagedBy = "terraform"
  }
}
