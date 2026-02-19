# AWS WAF Security Framework

[![Terraform CI](https://github.com/mason5052/aws-waf-security-framework/actions/workflows/terraform.yml/badge.svg)](https://github.com/mason5052/aws-waf-security-framework/actions/workflows/terraform.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-844FBA?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-WAFv2-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/waf/)

Production-tested AWS WAF implementation for eCommerce platforms. Achieved 90%+ threat reduction and reduced bot traffic from 30%+ to under 3% across global web properties (US, EU, AU, MX).

---

## Quick Start

```bash
# Clone
git clone https://github.com/mason5052/aws-waf-security-framework.git
cd aws-waf-security-framework

# Configure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your ALB ARN, SNS topic, and preferences

# Optional: configure remote state
cp backend.tf.example backend.tf
# Edit backend.tf with your S3 bucket details

# Deploy
terraform init
terraform plan
terraform apply
```

### Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured with appropriate IAM permissions
- An existing ALB and SNS topic
- AWS provider credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` or IAM role)

---

## Problem

Global eCommerce platforms face constant threats from automated bots, credential stuffing, DDoS attacks, and API abuse. Without a comprehensive WAF strategy:

- Bot traffic consumed 30%+ of infrastructure resources
- API endpoints were vulnerable to abuse and data scraping
- No centralized threat detection or automated response
- Manual security reviews could not keep up with evolving threats
- Multiple regional sites (US, EU, AU, MX) each needed protection

## Architecture

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
            Frontend        (Backend)
                              |
                        Backend Services
```

### WAF Rule Groups

| Priority | Rule | Description |
|----------|------|-------------|
| 1 | Bot Control | AWS Managed Bot Control for automated traffic classification |
| 2 | IP Reputation | AWS IP Reputation list blocking known malicious IPs |
| 3 | Global Rate Limit | IP-based rate limiting (configurable threshold) |
| 4 | API Rate Limit | URI-scoped rate limiting for `/api/` endpoints |
| 5 | Geo Blocking | Optional geographic restriction by country code |

> **Implementation Scope:** This module deploys a `REGIONAL`-scoped WebACL attached directly to the ALB. The architecture diagram above reflects the full production topology. For CloudFront WAF protection, AWS requires a separate `CLOUDFRONT`-scoped WebACL deployed in `us-east-1` — both WebACLs can run independently for layered protection across the CDN and origin tiers.

---

## Repository Structure

```
aws-waf-security-framework/
├── main.tf                    # WAF WebACL, rules, ALB association, CloudWatch alarm
├── variables.tf               # Input variables with validation rules
├── outputs.tf                 # WebACL ARN, ID, name, alarm ARN
├── versions.tf                # Terraform and provider version constraints
├── terraform.tfvars.example   # Example variable values (copy to terraform.tfvars)
├── backend.tf.example         # S3 remote state backend template
├── .gitignore                 # Terraform-specific ignores
├── LICENSE                    # MIT License
└── .github/
    └── workflows/
        └── terraform.yml      # CI: fmt, validate, tfsec, Checkov
```

---

## Configuration

All variables support input validation. See `terraform.tfvars.example` for a complete reference.

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `project_name` | string | `ecommerce` | Resource naming prefix (lowercase, hyphens) |
| `aws_region` | string | `us-east-1` | AWS deployment region |
| `alb_arn` | string | required | ALB ARN to protect |
| `sns_topic_arn` | string | required | SNS topic for alarm notifications |
| `global_rate_limit` | number | `2000` | Requests per 5min per IP (global) |
| `api_rate_limit` | number | `100` | API requests per 5min per IP |
| `blocked_countries` | list(string) | `[]` | ISO 3166-1 alpha-2 country codes |
| `block_alarm_threshold` | number | `1000` | Blocked requests to trigger alarm |
| `tags` | map(string) | see default | Resource tags |

---

## CI/CD Pipeline

The GitHub Actions workflow runs on every push and PR:

| Job | Description |
|-----|-------------|
| `validate` | `terraform fmt` check + `terraform validate` |
| `tfsec` | Static security analysis (SARIF to GitHub Security tab) |
| `checkov` | Terraform policy compliance scanning |

---

## Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Bot traffic | 30%+ of requests | <3% of requests | 90%+ reduction |
| API abuse incidents | 5-10/week | <1/month | 95% reduction |
| Manual security reviews | 10+ hours/week | 2 hours/week | 80% reduction |
| Threat detection time | Hours to days | Real-time | Automated |
| False positive rate | N/A | <0.1% | Minimal impact |

---

## Key Learnings

1. **Start with managed rules** - AWS Managed Rule Groups provide a solid baseline
2. **Layer custom rules** - Application-specific rules catch what managed rules miss
3. **Monitor before blocking** - Use COUNT mode first, switch to BLOCK after tuning
4. **Automate IP list updates** - Integrate threat intelligence feeds for dynamic blocking
5. **Regional considerations** - Different regions may need different rule configurations

---

## Tech Stack

- **WAF:** AWS WAFv2 (WebACL, Rule Groups, IP Sets) - REGIONAL scope (ALB)
- **IaC:** Terraform >= 1.5 with input validation, tfsec, Checkov, CI/CD gates
- **CDN:** CloudFront (CloudFront WAF requires separate CLOUDFRONT-scoped WebACL in us-east-1)
- **Monitoring:** CloudWatch Metrics + Alarms, SNS notifications
- **Logging:** CloudWatch Logs (WAF sampled requests + block events)
- **Compliance:** GDPR/CCPA aligned

---

## License

MIT License - see [LICENSE](./LICENSE) for details.

---

## Author

**Mason Kim** - DevSecOps Engineer
- [LinkedIn](https://www.linkedin.com/in/junkukkim)
- HashiCorp Certified: Terraform Associate (004)
- Certified Ethical Hacker (CEH) - EC-Council
- MS Cybersecurity, Georgia Institute of Technology (In Progress)
