# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-22

### Added
- Reusable WAF regional module (`modules/waf-regional/`)
- AWS Managed Rule Groups: Common Rule Set, SQLi, Known Bad Inputs, IP Reputation
- Rate-based rule with configurable threshold
- Geo-blocking by country code
- IP whitelisting via WAFv2 IP sets
- CloudWatch metrics and WAF logging with filter support
- ALB association resource
- Basic usage example (`examples/basic/`)
- CI pipeline with Terraform fmt/validate, tfsec, and Checkov
- MIT License

[1.0.0]: https://github.com/mason5052/aws-waf-security-framework/releases/tag/v1.0.0
