# AWS WAF Security Framework - Main Configuration
# Production-tested WAF implementation for eCommerce platforms

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# WAF WebACL
resource "aws_wafv2_web_acl" "ecommerce" {
  name        = "${var.project_name}-waf"
  description = "WAF WebACL for eCommerce platform protection"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Rule 1: AWS Managed Bot Control
  rule {
    name     = "AWSManagedBotControl"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-bot-control"
      sampled_requests_enabled   = true
    }
  }

  # Rule 2: AWS IP Reputation List
  rule {
    name     = "AWSIPReputationList"
    priority = 2

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
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-ip-reputation"
      sampled_requests_enabled   = true
    }
  }

  # Rule 3: Rate Limiting - Global
  rule {
    name     = "RateLimitGlobal"
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.global_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-rate-limit-global"
      sampled_requests_enabled   = true
    }
  }

  # Rule 4: Rate Limiting - API Endpoints
  rule {
    name     = "RateLimitAPI"
    priority = 4

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.api_rate_limit
        aggregate_key_type = "IP"

        scope_down_statement {
          byte_match_statement {
            search_string = "/api/"
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
            positional_constraint = "STARTS_WITH"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-rate-limit-api"
      sampled_requests_enabled   = true
    }
  }

  # Rule 5: Geo Blocking (optional)
  dynamic "rule" {
    for_each = length(var.blocked_countries) > 0 ? [1] : []

    content {
      name     = "GeoBlocking"
      priority = 5

      action {
        block {}
      }

      statement {
        geo_match_statement {
          country_codes = var.blocked_countries
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.project_name}-geo-blocking"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-waf"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.ecommerce.arn
}

# CloudWatch Alarm for high block rate
resource "aws_cloudwatch_metric_alarm" "waf_high_blocks" {
  alarm_name          = "${var.project_name}-waf-high-blocks"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = 300
  statistic           = "Sum"
  threshold           = var.block_alarm_threshold

  dimensions = {
    WebACL = aws_wafv2_web_acl.ecommerce.name
    Region = var.aws_region
    Rule   = "ALL"
  }

  alarm_actions = [var.sns_topic_arn]

  tags = var.tags
}
