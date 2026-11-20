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

Planned: S3 JSON incident reports, optional manually approved EC2 isolation.
