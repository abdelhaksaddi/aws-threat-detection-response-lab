"""AWS CloudWatch Alarm State Change -> SNS email notification.
Requires SNS_TOPIC_ARN and sns:Publish permission. No EC2 modification.
"""
import os
import boto3

sns = boto3.client("sns")

def lambda_handler(event, context):
    detail = event.get("detail", {})
    alarm = detail.get("alarmName", "Unknown")
    state = detail.get("state", {}).get("value", "UNKNOWN")

    if state != "ALARM":
        return {"status": "ignored", "state": state}

    message = f"""AWS SECURITY ALERT

Alarm: {alarm}
State: {state}
Region: {event.get('region', 'Unknown')}
Time: {event.get('time', 'Unknown')}

A monitored EC2 identity-file operation was detected.
Investigate CloudWatch audit logs; a matching event is not proof of an attack.
"""
    result = sns.publish(
        TopicArn=os.environ["SNS_TOPIC_ARN"],
        Subject="AWS Security Lab - Security Alert",
        Message=message,
    )
    return {"status": "sent", "message_id": result["MessageId"]}
