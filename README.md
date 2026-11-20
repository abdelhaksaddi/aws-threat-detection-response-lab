# AWS Automated Threat Detection & Response — Academic Lab

An AWS Academy lab for Linux security-event monitoring and automated email notification.

> **Status — 20 November 2026:** The live AWS resources were deployed through AWS CLI, **not Terraform**. The EventBridge-to-Lambda target is configured, and an automatic security email was reported received. S3 incident reporting is now deployed and verified with a simulated Lambda event; EC2 containment is not deployed.

## Architecture

![AWS security lab architecture](docs/arch.png)

```mermaid
flowchart LR
  EC2["Ubuntu EC2 + auditd"] --> AG["CloudWatch Agent"]
  AG --> LOG["CloudWatch Logs"]
  LOG --> MF["Metric Filter"]
  MF --> AL["CloudWatch Alarm"]
  AL --> EB["EventBridge"]
  EB --> L["Python Lambda"]
  L --> SNS["SNS Topic"]
  SNS --> MAIL["Security email"]
  L --> S3["S3 incident reports (SSE-S3)"]
```

## Existing AWS infrastructure

| Component | Resource | Status |
|---|---|---|
| Network | VPC `security-lab-vpc` (`10.0.0.0/16`), public subnet `10.0.1.0/24` | Deployed |
| Compute | Ubuntu EC2 `i-02b37eb63cdd1fc7f` | Deployed |
| Host monitoring | `auditd` identity-file watch on `/etc/passwd` | Tested |
| Log collection | CloudWatch Agent to `/security-lab/ubuntu/auditd` | Tested |
| Detection | Metric `SecurityLab/IdentityFileChanges` | Tested |
| Alarm | `SecurityLab-IdentityFileChange` | Observed OK → ALARM |
| Routing | `SecurityLab-Alarm-Rule` | Target configured |
| Handler | `SecurityLab-IncidentResponse` | Active |
| Notification | SNS `security-lab-alerts` | Email reported received |
| Reporting | S3 incident JSON in `security-lab-incidents-007712891456-us-east-1` | Tested with simulated alarm |
| Remediation | Manual approval-gated containment | Planned |

## Repository layout

- `lambda/`: Python SNS + S3 incident handler
- `auditd/`: Linux audit rule
- `cloudwatch/`: CloudWatch Agent template and detection configuration
- `terraform/`: **read-only Terraform discovery** of existing infrastructure
- `scripts/`: PowerShell inventory and Lambda test
- `docs/`: validation steps and project presentation notes

## AWS CLI + AWS Academy setup (Windows)

Follow the complete [Windows AWS CLI installation and Academy credentials guide](docs/aws-cli-setup-windows.md) before running commands. It explains how to create the local `.aws` directory, configure `credentials` and `config` with temporary Learner Lab credentials, set the `academy` profile, and test access without exposing secrets.

Use [placeholder config](examples/config.example) and [placeholder credentials](examples/credentials.example), **never real keys in GitHub**. Check the connection read-only from the project root using `.\scripts\Check-AwsAcademy.ps1`.

## Quick start

```powershell
cd terraform
terraform init
terraform validate
terraform plan
```

The Terraform `data` blocks read existing AWS resources; they **do not deploy, own, or import them**. The EC2 data lookup assumes a `Name=security-lab-ec2` tag: verify this first, because the instance was originally identified by instance ID.

## LAB 14 — S3 Incident Reporting

The existing Lambda function `SecurityLab-IncidentResponse` now uses `SNS_TOPIC_ARN` and `INCIDENT_BUCKET`. For a CloudWatch `ALARM` event, it publishes an SNS email and writes a JSON incident report to S3 using SSE-S3 (`AES256`). A successful simulated invocation returned `status: sent` and the S3 object was independently verified with `head-object` (`application/json`, 556 bytes, `AES256`).

Example path: `incidents/2026/11/20/incident-9141e9f5-bf42-4a48-842d-bef39492ed45.json`.

These results verify a direct Lambda test; they do **not** by themselves prove the updated S3 branch was exercised through a new live auditd → EventBridge end-to-end alarm. No S3 event payloads, credential files or logs containing secrets are committed.

## Security

- Never commit AWS access keys, session tokens, `.pem` files, Terraform state, real audit logs, or environment files.
- Keep this repository private during development.
- `chmod --reference=/etc/passwd /etc/passwd` is a harmless monitored operation, **not a real intrusion**.
- Do not automate EC2 isolation based solely on one identity-file event.

## Sources

- [AWS CloudWatch and EventBridge](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch-and-eventbridge.html)
- [CloudWatch Logs metric filters](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/MonitoringLogData.html)
- [AWS Lambda Python packages](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html)
- [HashiCorp Terraform imports](https://developer.hashicorp.com/terraform/language/import)
- [GitHub secret safety](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
