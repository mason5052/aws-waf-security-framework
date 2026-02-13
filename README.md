# AWS WAF Security Framework

A production-tested AWS WAF implementation framework for eCommerce platforms, achieving 90%+ threat reduction across global web properties.

## Problem

Global eCommerce platforms face constant threats from automated bots, credential stuffing, DDoS attacks, and API abuse. Without a comprehensive WAF strategy:

- Bot traffic consumed 30%+ of infrastructure resources
- API endpoints were vulnerable to abuse and data scraping
- No centralized threat detection or automated response
- Manual security reviews could not keep up with evolving threats
- Multiple regional sites (US, EU, AU, MX) each needed protection

## Solution Architecture

```
                    Internet
                       |
                   CloudFront
                       |
                   AWS WAF
                  /    |    \
          Rate     IP      Managed
         Limiting  Sets    Rule Groups
                       |
               Application Load Balancer
                  /         \
            Shopify        API Gateway
            Frontend        (Wonder Server)
                              |
                        Backend Services
```

### WAF Rule Groups

1. **Bot Control** - AWS Managed Bot Control rule group for automated traffic classification
2. **Rate Limiting** - IP-based and URI-based rate limiting to prevent abuse
3. **IP Reputation** - AWS IP Reputation list blocking known malicious IPs
4. **Geo Blocking** - Block traffic from non-operational regions
5. **Custom Rules** - Application-specific rules for API protection

### Terraform Module Structure

```
modules/
  waf/
    main.tf          # WAF WebACL and rule group definitions
    variables.tf     # Configurable thresholds and rule parameters
    outputs.tf       # WebACL ARN and metrics
    rules/
      bot-control.tf     # Bot detection rules
      rate-limiting.tf   # Rate limiting configuration
      ip-reputation.tf   # IP reputation lists
      geo-blocking.tf    # Geographic restrictions
      custom-rules.tf    # Application-specific rules
```

## Implementation Details

### Rate Limiting Configuration

```hcl
# Example: API endpoint rate limiting
resource "aws_wafv2_rate_based_statement" "api_rate_limit" {
  limit              = 100
  aggregate_key_type = "IP"

  scope_down_statement {
    byte_match_statement {
      search_string         = "/api/"
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
```

### Bot Control

```hcl
# Example: AWS Managed Bot Control
resource "aws_wafv2_web_acl" "main" {
  name  = "ecommerce-waf"
  scope = "REGIONAL"

  rule {
    name     = "AWSManagedRulesBotControlRuleSet"
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
      metric_name                = "BotControlMetric"
      sampled_requests_enabled   = true
    }
  }
}
```

### Monitoring & Alerting

```hcl
# CloudWatch alarm for high block rate
resource "aws_cloudwatch_metric_alarm" "waf_high_block_rate" {
  alarm_name          = "waf-high-block-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = 300
  statistic           = "Sum"
  threshold           = 1000

  dimensions = {
    WebACL = aws_wafv2_web_acl.main.name
    Region = var.aws_region
    Rule   = "ALL"
  }

  alarm_actions = [var.sns_topic_arn]
}
```

## Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Bot traffic | 30%+ of requests | <3% of requests | 90%+ reduction |
| API abuse incidents | 5-10/week | <1/month | 95% reduction |
| Manual security reviews | 10+ hours/week | 2 hours/week | 80% reduction |
| Threat detection time | Hours to days | Real-time | Automated |
| False positive rate | N/A | <0.1% | Minimal impact |

## Tech Stack

- **WAF:** AWS WAFv2 (WebACL, Rule Groups, IP Sets)
- **IaC:** Terraform (modular configuration)
- **CDN:** CloudFront
- **Monitoring:** CloudWatch Metrics + Alarms, SNS notifications
- **Logging:** WAF Logs -> S3 -> analysis
- **Compliance:** GDPR, CCPA aligned

## Key Learnings

1. **Start with managed rules** - AWS Managed Rule Groups provide good baseline protection
2. **Layer custom rules on top** - Application-specific rules catch what managed rules miss
3. **Monitor before blocking** - Use COUNT mode first, then switch to BLOCK after tuning
4. **Automate IP list updates** - Integrate threat intelligence feeds for dynamic blocking
5. **Regional considerations** - Different regions may need different rule configurations

## Author

**Mason Kim** - DevSecOps / Platform Security Engineer
- [LinkedIn](https://www.linkedin.com/in/junkukkim)
- HashiCorp Certified: Terraform Associate (004)
- Certified Ethical Hacker (CEH) - EC-Council
- MS Cybersecurity, Georgia Institute of Technology (In Progress)
