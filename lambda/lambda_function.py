"""CloudWatch ALARM -> SNS email + S3 JSON incident report.

Existing AWS Academy Lambda: SecurityLab-IncidentResponse (us-east-1)
Environment: SNS_TOPIC_ARN, INCIDENT_BUCKET

The /etc/passwd audit rule detects monitored file operations; it does not
prove malicious activity. S3 failures are logged without undoing SNS alerts.
"""
import boto3
import os
import json
import uuid
import logging
from datetime import datetime, timezone
from botocore.exceptions import ClientError

sns = boto3.client("sns")
s3 = boto3.client("s3")
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    detail = event.get("detail", {})
    alarm = detail.get("alarmName", "Unknown")
    state_detail = detail.get("state", {})
    state = state_detail.get("value", "UNKNOWN")

    if state != "ALARM":
        return {"status": "ignored", "state": state}

    incident_id = str(uuid.uuid4())
    now = datetime.now(timezone.utc)
    bucket = os.environ["INCIDENT_BUCKET"]

    incident = {
        "incident_id": incident_id,
        "incident_type": "Identity File Activity",
        "severity": "MEDIUM",
        "status": "OPEN",
        "alarm_name": alarm,
        "alarm_state": state,
        "detected_at": now.isoformat(),
        "event_time": event.get("time"),
        "region": event.get("region", "unknown"),
        "account_id": event.get("account"),
        "source": event.get("source", "aws.cloudwatch"),
        "event_id": event.get("id"),
        "resources": event.get("resources", []),
        "description": "Monitored identity-file operation; requires investigation."
    }

    message = f"""
AWS SECURITY ALERT

Incident ID: {incident_id}
Alarm: {alarm}
State: {state}
Region: {incident['region']}
Time: {incident['event_time']}

Action: Investigate CloudWatch audit logs.
"""

    # Preserve existing SNS notification
    response = sns.publish(
        TopicArn=os.environ["SNS_TOPIC_ARN"],
        Subject="AWS Security Lab - Security Alert",
        Message=message
    )

    # Save incident report to Amazon S3
    key = (
        f"incidents/{now:%Y/%m/%d}/"
        f"incident-{incident_id}.json"
    )

    try:
        s3.put_object(
            Bucket=bucket,
            Key=key,
            Body=json.dumps(incident, indent=2).encode("utf-8"),
            ContentType="application/json",
            ServerSideEncryption="AES256"
        )

        logger.info("Incident report stored at s3://%s/%s", bucket, key)

        return {
            "status": "sent",
            "incident_id": incident_id,
            "sns_message_id": response["MessageId"],
            "s3_bucket": bucket,
            "s3_key": key
        }

    except ClientError:
        logger.exception("S3 incident report upload failed")
        return {
            "status": "email_sent_s3_failed",
            "incident_id": incident_id
        }
