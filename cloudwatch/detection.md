# CloudWatch detection

- Log group: `/security-lab/ubuntu/auditd`, 7-day retention
- Metric filter: `IdentityFileWatchFilter`
- Filter pattern: `%^type=SYSCALL.*identity-file-watch%`
- Metric namespace/name: `SecurityLab/IdentityFileChanges`
- Metric value: `1`, default: `0`
- Alarm: `SecurityLab-IdentityFileChange`
- Threshold: sum >= 1, one 60-second evaluation period; missing data `notBreaching`
- EventBridge rule: `SecurityLab-Alarm-Rule`, matches state `ALARM`

The filter matches monitored identity-file syscalls, **not confirmed malicious activity**.

Verify:
```powershell
aws logs describe-metric-filters --profile academy --region us-east-1 --log-group-name /security-lab/ubuntu/auditd
```

[CloudWatch filter pattern syntax](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html)
