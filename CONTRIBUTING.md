# Contributing to AWS WAF Security Framework

Thank you for your interest in contributing to this project. This guide explains the process for contributing.

## How to Contribute

### Reporting Issues

- Use GitHub Issues to report bugs or request features
- Include Terraform version, AWS provider version, and relevant configuration
- For security vulnerabilities, see [SECURITY.md](SECURITY.md)

### Submitting Changes

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Ensure all checks pass (see below)
5. Submit a pull request

### Code Standards

All Terraform code must pass these checks before merging:

```bash
# Format check
terraform fmt -check -recursive -diff

# Initialize and validate
terraform init -backend=false
terraform validate

# Security scan
tfsec .

# Policy compliance
checkov -d . --framework terraform
```

### Style Guide

- Run `terraform fmt` before committing
- Use descriptive variable names with `description` attributes
- Add `tags` support to all resources
- Include `visibility_config` on all WAF rules
- Document all variables in `variables.tf` with descriptions and defaults

### Testing

- Test module changes with the `examples/basic/` configuration
- Verify `terraform plan` succeeds with example variables
- Confirm no new tfsec or Checkov findings without justification

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
