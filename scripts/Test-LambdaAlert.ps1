# Safe simulated alarm invocation; triggers an actual SNS email if Lambda has permission.
param([string]$Profile='academy', [string]$Region='us-east-1')
$ErrorActionPreference='Stop'
$event = @{
  source = 'aws.cloudwatch'
  'detail-type' = 'CloudWatch Alarm State Change'
  region = $Region
  time = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
  detail = @{ alarmName = 'SecurityLab-IdentityFileChange'; state = @{ value = 'ALARM' } }
} | ConvertTo-Json -Depth 6

$tmp=Join-Path ([System.IO.Path]::GetTempPath()) ('security-lab-'+[guid]::NewGuid()+'.json')
$out=Join-Path ([System.IO.Path]::GetTempPath()) ('security-lab-response-'+[guid]::NewGuid()+'.json')
try {
  [System.IO.File]::WriteAllText($tmp,$event,(New-Object System.Text.UTF8Encoding($false)))
  aws lambda invoke --profile $Profile --region $Region --function-name SecurityLab-IncidentResponse --payload "fileb://$tmp" $out
  if ($LASTEXITCODE -ne 0) { throw 'Lambda invocation failed.' }
  Get-Content $out -Raw
} finally {
  Remove-Item $tmp,$out -ErrorAction SilentlyContinue
}
