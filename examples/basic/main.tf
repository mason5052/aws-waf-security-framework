# ============================================================================
# Basic WAF Example
# Demonstrates simple WAF setup with default protections
# Author: Mason Kim (https://github.com/mason5052)
# ============================================================================

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ============================================================================
# WAF Module
# ============================================================================

module "waf" {
  source = "../../modules/waf-regional"

  name_prefix = "basic-example"

  # Enable default protections
  enable_common_rules              = true
  enable_sql_injection_protection  = true
  enable_known_bad_inputs_protection = true
  enable_ip_reputation_protection  = true

  # Rate limiting
  enable_rate_limiting   = true
  rate_limit_threshold   = 2000

  # Associate with ALB (optional)
  alb_arn = var.alb_arn

  # CloudWatch metrics
  enable_cloudwatch_metrics = true

  tags = {
    Environment = "example"
    Project     = "waf-basic-demo"
    ManagedBy   = "terraform"
  }
}

# ============================================================================
# Variables
# ============================================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "alb_arn" {
  description = "ARN of ALB to associate with WAF (optional)"
  type        = string
  default     = ""
}

# ============================================================================
# Outputs
# ============================================================================

output "web_acl_id" {
  description = "WAF Web ACL ID"
  value       = module.waf.web_acl_id
}

output "web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = module.waf.web_acl_arn
}
