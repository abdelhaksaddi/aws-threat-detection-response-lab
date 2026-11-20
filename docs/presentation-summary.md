# Academic project presentation overview

**Title:** AWS Automated Threat Detection & Incident Notification

**Problem:** Important Linux host changes may be logged without timely security notifications.

**Objective:** Build an event-driven monitoring and notification pipeline with Ubuntu EC2, auditd, CloudWatch Agent, CloudWatch Logs, metric filters, alarms, EventBridge, AWS Lambda and SNS.

**Scope:** VPC `10.0.0.0/16`, public subnet `10.0.1.0/24`, Ubuntu EC2, watch on `/etc/passwd`, CloudWatch log collection, identity-file metric/alarm, EventBridge routing and SNS email.

**Test:** Benign `chmod --reference=/etc/passwd /etc/passwd` creates auditable activity; the application can alert on matching events. A logged audit event does not imply malicious intent.

**IaC maturity:** AWS CLI deployed current services. Terraform files only read existing infrastructure. Full Terraform management will require deliberate import and drift review.

**Next phases:** S3 incident report storage, permission review, scoped incident-response simulations and improved documentation.
