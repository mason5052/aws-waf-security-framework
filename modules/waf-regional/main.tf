# ============================================================================
# AWS WAF Regional Module - Main Configuration
# Production-tested WAF rules achieving 90%+ threat reduction
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

# ============================================================================
# Local Variables
# ============================================================================

locals {
  waf_name = "${var.name_prefix}-waf"
  
  default_tags = merge(var.tags, {
    ManagedBy = "terraform"
    Module    = "terraform-aws-waf-security"
  })
}

# ============================================================================
# WAF Web ACL
# ============================================================================

resource "aws_wafv2_web_acl" "main" {
  name        = local.waf_name
  description = "WAF Web ACL for ${var.name_prefix}"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # ----------------------------------------------------------------------------
  # AWS Managed Rules - Common Rule Set
  # ----------------------------------------------------------------------------
  dynamic "rule" {
    for_each = var.enable_common_rules ? [1] : []
    content {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 10

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${local.waf_name}-common-rules"
        sampled_requests_enabled   = true
      }
    }
  }

  # ----------------------------------------------------------------------------
  # AWS Managed Rules - SQL Injection Protection
  # ----------------------------------------------------------------------------
  dynamic "rule" {
    for_each = var.enable_sql_injection_protection ? [1] : []
    content {
      name     = "AWSManagedRulesSQLiRuleSet"
      priority = 20

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesSQLiRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${local.waf_name}-sqli-rules"
        sampled_requests_enabled   = true
      }
    }
  }

  # ----------------------------------------------------------------------------
  # AWS Managed Rules - Known Bad Inputs
  # ----------------------------------------------------------------------------
  dynamic "rule" {
    for_each = var.enable_known_bad_inputs_protection ? [1] : []
    content {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 30

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesKnownBadInputsRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${local.waf_name}-bad-inputs"
        sampled_requests_enabled   = true
      }
    }
  }

  # ----------------------------------------------------------------------------
  # AWS Managed Rules - IP Reputation List
  # ----------------------------------------------------------------------------
  dynamic "rule" {
    for_each = var.enable_ip_reputation_protection ? [1] : []
    content {
      name     = "AWSManagedRulesAmazonIpReputationList"
      priority = 40

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAmazonIpReputationList"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${local.waf_name}-ip-reputation"
        sampled_requests_enabled   = true
      }
    }
  }

  # ----------------------------------------------------------------------------
  # Rate-Based Rule
  # ----------------------------------------------------------------------------
  dynamic "rule" {
    for_each = var.enable_rate_limiting ? [1] : []
    content {
      name     = "RateLimitRule"
      priority = 50

      action {
        block {}
      }

      statement {
        rate_based_statement {
          limit              = var.rate_limit_threshold
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${local.waf_name}-rate-limit"
        sampled_requests_enabled   = true
      }
    }
  }

  # ----------------------------------------------------------------------------
  # Geo-Blocking Rule
  # ----------------------------------------------------------------------------
  dynamic "rule" {
    for_each = length(var.blocked_countries) > 0 ? [1] : []
    content {
      name     = "GeoBlockRule"
      priority = 60

      action {
        block {}
      }

      statement {
        geo_match_statement {
          country_codes = var.blocked_countries
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${local.waf_name}-geo-block"
        sampled_requests_enabled   = true
      }
    }
  }

  # ----------------------------------------------------------------------------
  # IP Whitelist Rule
  # ----------------------------------------------------------------------------
  dynamic "rule" {
    for_each = length(var.ip_whitelist) > 0 ? [1] : []
    content {
      name     = "IPWhitelistRule"
      priority = 1

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.whitelist[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
        metric_name                = "${local.waf_name}-ip-whitelist"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.enable_cloudwatch_metrics
    metric_name                = local.waf_name
    sampled_requests_enabled   = true
  }

  tags = local.default_tags
}

# ============================================================================
# IP Set for Whitelisting
# ============================================================================

resource "aws_wafv2_ip_set" "whitelist" {
  count = length(var.ip_whitelist) > 0 ? 1 : 0

  name               = "${local.waf_name}-whitelist"
  description        = "IP whitelist for ${var.name_prefix}"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.ip_whitelist

  tags = local.default_tags
}

# ============================================================================
# Web ACL Association with ALB
# ============================================================================

resource "aws_wafv2_web_acl_association" "alb" {
  count = var.alb_arn != "" ? 1 : 0

  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# ============================================================================
# CloudWatch Logging (Optional)
# ============================================================================

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  count = var.enable_logging ? 1 : 0

  log_destination_configs = var.log_destination_arns
  resource_arn            = aws_wafv2_web_acl.main.arn

  dynamic "logging_filter" {
    for_each = var.log_filter_enabled ? [1] : []
    content {
      default_behavior = "DROP"

      filter {
        behavior    = "KEEP"
        requirement = "MEETS_ANY"

        condition {
          action_condition {
            action = "BLOCK"
          }
        }
      }
    }
  }
}
