# Read-only AWS Academy lab inventory.
param([string]$Profile='academy', [string]$Region='us-east-1')
$ErrorActionPreference='Stop'
$common=@('--profile',$Profile,'--region',$Region)

Write-Host '== VPC =='
aws ec2 describe-vpcs @common --filters 'Name=tag:Name,Values=security-lab-vpc' --query 'Vpcs[].{Id:VpcId,CIDR:CidrBlock}' --output table
Write-Host '== EC2 =='
aws ec2 describe-instances @common --instance-ids 'i-02b37eb63cdd1fc7f' --query 'Reservations[].Instances[].{ID:InstanceId,State:State.Name}' --output table
Write-Host '== Alarm =='
aws cloudwatch describe-alarms @common --alarm-names 'SecurityLab-IdentityFileChange' --query 'MetricAlarms[].{Name:AlarmName,State:StateValue}' --output table
Write-Host '== EventBridge Target =='
aws events list-targets-by-rule @common --rule 'SecurityLab-Alarm-Rule' --query 'Targets[].{ID:Id,ARN:Arn}' --output table
Write-Host '== Lambda =='
aws lambda get-function-configuration @common --function-name 'SecurityLab-IncidentResponse' --query '{Name:FunctionName,State:State}' --output table
