# Validation evidence

Observed on 20 Nov 2026:

1. `sudo auditctl -l` showed `-w /etc/passwd -p wa -k identity-file-watch`.
2. `sudo chmod --reference=/etc/passwd /etc/passwd` produced an audit `SYSCALL` record tagged `identity-file-watch`.
3. CloudWatch log ingestion and matching metric datapoints were previously confirmed.
4. CloudWatch alarm history showed `OK → ALARM` transitions.
5. Lambda `SecurityLab-IncidentResponse` reported `Active`.
6. EventBridge rule target pointed at this Lambda.
7. User reported receiving an automatic email.

For rigorous end-to-end verification, preserve contemporaneous CloudWatch alarm history, EventBridge/Lambda metrics and Lambda logs from the **same** test window; the historical transition shown before the latest test was not sufficient by itself to time-correlate the final notification.

This lab demonstrates monitoring and alerting, **not proof of intrusion**.

## LAB 14 — S3 incident-report test (20 November 2026)

- S3 bucket: `security-lab-incidents-007712891456-us-east-1`
- Public access block verified: all four S3 public-access flags `True`.
- IAM simulator evaluated `s3:PutObject` as `allowed` for the Lambda execution role `LabRole`.
- Existing Lambda environment variables preserved: `SNS_TOPIC_ARN`, plus new `INCIDENT_BUCKET`.
- Updated Lambda code deployed; state `Active`, update `Successful`.
- Direct Lambda simulation returned `StatusCode: 200` and handler response `status: sent`, SNS `message_id`, S3 bucket and object key.
- Incident ID: `9141e9f5-bf42-4a48-842d-bef39492ed45` (simulated event).
- S3 key: `incidents/2026/11/20/incident-9141e9f5-bf42-4a48-842d-bef39492ed45.json`.
- S3 list confirmed the JSON object existed (556 bytes); `head-object` confirmed `ContentType=application/json` and `ServerSideEncryption=AES256`.
- SNS publish succeeded, but email delivery for this particular invocation was not separately confirmed in its test output.
- Scope of validation: **direct simulated Lambda invocation**; a new live end-to-end auditd/CloudWatch/EventBridge/S3 run has not yet been verified.

Planned: optional manually approved EC2 isolation and more comprehensive end-to-end tests.
