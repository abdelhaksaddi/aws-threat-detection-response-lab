# Terraform read-only inventory

Existing resources were deployed with AWS CLI. The `data` blocks discover them, but Terraform does **not** yet manage or create them.

```powershell
terraform init
terraform validate
terraform plan
```

Requires Terraform and the configured `academy` AWS CLI profile.

## Future managed Infrastructure as Code

1. Capture complete configuration with read-only AWS CLI queries.
2. Define Terraform resource blocks matching the existing services.
3. Use Terraform `import` blocks (or `terraform import`) one resource at a time.
4. Review every proposed change before any `apply`.
5. Do not run `terraform destroy` against the live lab.

Keep `*.tfstate`, `.terraform/`, plans, credentials and token files out of GitHub.

[Official Terraform import docs](https://developer.hashicorp.com/terraform/language/import)
