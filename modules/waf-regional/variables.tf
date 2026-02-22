# ============================================================================
# AWS WAF Regional Module - Variables
# Author: Mason Kim (https://github.com/mason5052)
# ============================================================================

# ----------------------------------------------------------------------------
# Required Variables
# ----------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

# ----------------------------------------------------------------------------
# Optional Variables - Feature Toggles
# ----------------------------------------------------------------------------

variable "enable_common_rules" {
  description = "Enable AWS Managed Common Rule Set"
  type        = bool
  default     = true
}

variable "enable_sql_injection_protection" {
  description = "Enable SQL injection protection rules"
  type        = bool
  default     = true
}

variable "enable_xss_protection" {
  description = "Enable XSS protection rules"
  type        = bool
  default     = true
}

variable "enable_known_bad_inputs_protection" {
  description = "Enable known bad inputs protection"
  type        = bool
  default     = true
}

variable "enable_ip_reputation_protection" {
  description = "Enable IP reputation list protection"
  type        = bool
  default     = true
}

variable "enable_rate_limiting" {
  description = "Enable rate limiting rule"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_metrics" {
  description = "Enable CloudWatch metrics for WAF"
  type        = bool
  default     = true
}

# ----------------------------------------------------------------------------
# Rate Limiting Configuration
# ----------------------------------------------------------------------------

variable "rate_limit_threshold" {
  description = "Number of requests per 5-minute period before rate limiting"
  type        = number
  default     = 2000
}

# ----------------------------------------------------------------------------
# Geo-Blocking Configuration
# ----------------------------------------------------------------------------

variable "blocked_countries" {
  description = "List of country codes to block (ISO 3166-1 alpha-2)"
  type        = list(string)
  default     = []
}

# ----------------------------------------------------------------------------
# IP Configuration
# ----------------------------------------------------------------------------

variable "ip_whitelist" {
  description = "List of IP addresses/CIDR blocks to whitelist"
  type        = list(string)
  default     = []
}

# ----------------------------------------------------------------------------
# Resource Association
# ----------------------------------------------------------------------------

variable "alb_arn" {
  description = "ARN of the Application Load Balancer to associate with WAF"
  type        = string
  default     = ""
}

# ----------------------------------------------------------------------------
# Logging Configuration
# ----------------------------------------------------------------------------

variable "enable_logging" {
  description = "Enable WAF logging"
  type        = bool
  default     = false
}

variable "log_destination_arns" {
  description = "List of ARNs for log destinations (Kinesis Firehose, CloudWatch, S3)"
  type        = list(string)
  default     = []
}

variable "log_filter_enabled" {
  description = "Enable logging filter to only log blocked requests"
  type        = bool
  default     = true
}

# ----------------------------------------------------------------------------
# Tags
# ----------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
