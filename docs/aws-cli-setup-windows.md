# AWS CLI v2 + AWS Academy Learner Lab — Windows setup

This guide is for **Windows 10/11 PowerShell** with an **AWS Academy Learner Lab**. It reproduces the local CLI setup used for this security-monitoring project.

> **Do not share AWS access keys, secret keys or session tokens in GitHub, screenshots, screenshots of terminal history, issues, commits, chat or pull requests.** They are sensitive even when short-lived.

## 1. Prerequisites

- Windows PowerShell (or PowerShell 7)
- Permission to install programs on your own PC
- Access to your AWS Academy Learner Lab
- A running Learner Lab session (**Start Lab**)
- Internet access

## 2. Install AWS CLI v2

Open [the official AWS CLI v2 Windows installation page](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

Download the Windows x64 MSI from [awscli.amazonaws.com/AWSCLIV2.msi](https://awscli.amazonaws.com/AWSCLIV2.msi), double-click and complete the installation.

Alternatively, in PowerShell:

```powershell
$msi = Join-Path $env:TEMP "AWSCLIV2.msi"
Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile $msi
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msi`"" -Wait
```

Open a **new** PowerShell window (so PATH reloads) and verify:

```powershell
aws --version
Get-Command aws
```

Expected: an `aws-cli/2.x` version; the exact version changes over time. If `aws` is not recognized, reopen your terminal or consult the [AWS CLI installation troubleshooting guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-troubleshooting.html).

**No need to reinstall AWS CLI when your Academy credentials expire.** Refresh the temporary credentials instead.

## 3. Obtain your temporary AWS Academy credentials

1. Open your **AWS Academy Learner Lab** course and select **Start Lab**; wait until the lab is ready.
2. Open **AWS Details** and find **AWS CLI** → **Show** (labels may differ between Academy lab versions).
3. The panel typically provides a credential block with these three entries:
   - `aws_access_key_id`
   - `aws_secret_access_key`
   - `aws_session_token`
4. Copy the values **only to your local credential file**. These credentials are temporary; when the lab session or token expires, repeat these steps.

Do not use your ordinary AWS Console email and password as AWS CLI credentials. These Learner Lab keys and session token are the API credentials.

## 4. Create the local .aws directory

From Windows PowerShell:

```powershell
New-Item -ItemType Directory -Path "$HOME\.aws" -Force | Out-Null
Test-Path "$HOME\.aws"
```

Expected: `True`.

The default directory is:

```text
C:\Users\<WINDOWS_USERNAME>\.aws\
├── credentials
└── config
```

It lives in your **Windows home directory**, **not inside the GitHub project**. The local directory will be read automatically by the AWS CLI.

## 5. Create the credentials file

Open the file locally:

```powershell
notepad "$HOME\.aws\credentials"
```

If Notepad offers to create the file, choose **Yes**. Paste the *three values* from your active Academy lab in this format (replace every placeholder locally):

```ini
[academy]
aws_access_key_id = <PASTE_LAB_ACCESS_KEY_HERE>
aws_secret_access_key = <PASTE_LAB_SECRET_KEY_HERE>
aws_session_token = <PASTE_LAB_SESSION_TOKEN_HERE>
```

Save as `credentials` (no `.txt` extension). The section must be `[academy]`, **not** `[profile academy]` in this file.

> The AWS Academy panel may show `[default]`. Changing that heading to `[academy]` lets you use the explicit `--profile academy` flag in this project. The session token is **required** for these temporary credentials.

To verify the file **exists without printing its secrets**:

```powershell
Test-Path "$HOME\.aws\credentials"
```

## 6. Create the region/config file

```powershell
notepad "$HOME\.aws\config"
```

Paste:

```ini
[profile academy]
region = us-east-1
output = json
```

Save as `config` (no `.txt` extension). In `config`, named profiles use `[profile academy]`, which intentionally differs from `[academy]` in `credentials`.

## 7. Verify authentication and lab account

```powershell
aws configure list-profiles
aws configure list --profile academy
aws sts get-caller-identity --profile academy --region us-east-1
```

The `get-caller-identity` output should identify your current AWS Academy account and role. For this lab, the expected **account ID is `007712891456`**. If it differs, **stop** and double-check your configured session and profile before running any commands that change resources.

A read-only resource check:

```powershell
aws ec2 describe-instances `
  --profile academy `
  --region us-east-1 `
  --instance-ids "i-02b37eb63cdd1fc7f" `
  --query "Reservations[].Instances[].{Id:InstanceId,State:State.Name}" `
  --output table
```

A missing resource may indicate the lab session has been reset or the account/region does not match; do not automatically create a replacement.

### Running AWS CLI commands in this project

Use the same named profile and region:

```powershell
aws lambda get-function-configuration `
  --profile academy `
  --region us-east-1 `
  --function-name SecurityLab-IncidentResponse `
  --query "{Name:FunctionName,State:State}" `
  --output table
```

Optional: for one PowerShell window, you can select your profile without changing your stored credentials:

```powershell
$env:AWS_PROFILE = "academy"
$env:AWS_DEFAULT_REGION = "us-east-1"
```

This does **not** log you in or refresh expired keys. Explicit `--profile academy` remains the safest choice for reproducible commands.

## 8. Refresh credentials when the Academy session changes

When you restart the Academy lab or the issued credentials expire:

1. Start the lab again and open **AWS Details → AWS CLI → Show**.
2. Open `notepad "$HOME\.aws\credentials"`.
3. Replace all **three** values under `[academy]` with the new access key, secret key and session token.
4. Save and rerun `aws sts get-caller-identity --profile academy --region us-east-1`.
5. Continue only if the account identity matches the intended lab.

Keep only one `[academy]` section; do not append duplicate sections or accidentally retain a previous session token.

## 9. Troubleshooting

| Error or symptom | Likely issue / action |
|---|---|
| `aws : The term 'aws' is not recognized` | AWS CLI not installed or PowerShell PATH has not reloaded; open a new terminal |
| `The config profile (academy) could not be found` | Missing or misspelled `[academy]` or `[profile academy]` |
| `Unable to locate credentials` | `credentials` file not present, wrong file extension, or wrong profile |
| `ExpiredToken` / `InvalidClientTokenId` | Start Academy lab and replace all three temporary credential values |
| `AccessDenied` | Correct credentials can still be restricted by Academy policy; inspect the specific denied API, don't attempt to bypass permissions |
| Wrong AWS account | Verify `--profile academy` and `aws sts get-caller-identity`; stop before modifying resources |
| CLI sees different credentials than the file | Check `aws configure list --profile academy` and environment-variable precedence; AWS CLI can read environment variables that override files |
| `File not found` for `.aws\credentials` | Check that Notepad didn't save `credentials.txt` and the path is the Windows home folder |

For Windows scripts, PowerShell backticks (`\` at the end of a line) must be the **last character** on that line.

## 10. Optional Terraform setup

Terraform is a **separate** installation: [official Terraform installation instructions](https://developer.hashicorp.com/terraform/install). After installing it:

```powershell
terraform -version
cd terraform
terraform init
terraform validate
terraform plan
```

The committed Terraform configuration currently uses **read-only data sources** to discover existing CLI-created resources. It does **not** provision or manage them. Avoid `terraform apply` or `terraform destroy` until the full IaC import is deliberately reviewed.

## Sources

- [AWS — Install or update AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [AWS — Configuration and credentials files](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [AWS — Short-term AWS CLI credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-short-term.html)
- [AWS — Profile settings and precedence](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
- [AWS — AWS CLI troubleshooting](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-troubleshooting.html)
- [AWS Builder Center — AWS Learner Lab credentials](https://builder.aws.com/content/3HjOGs0uQA2SkohkLbgRNgcWnbt/preparando-a-maquina-para-o-aws-learner-lab)
