#requires -Version 5.1
[CmdletBinding()]
param([string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'BitLocker_Readiness_Reports'}
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
$volumes=Get-BitLockerVolume -ErrorAction SilentlyContinue|ForEach-Object{[PSCustomObject]@{MountPoint=$_.MountPoint;VolumeType=$_.VolumeType;ProtectionStatus=$_.ProtectionStatus;VolumeStatus=$_.VolumeStatus;EncryptionMethod=$_.EncryptionMethod;EncryptionPercentage=$_.EncryptionPercentage;AutoUnlockEnabled=$_.AutoUnlockEnabled;KeyProtectorTypes=($_.KeyProtector.KeyProtectorType -join ', ')}}
$tpm=Get-Tpm -ErrorAction SilentlyContinue|Select-Object TpmPresent,TpmReady,TpmEnabled,TpmActivated,ManufacturerIdTxt,ManufacturerVersion
$summary=[PSCustomObject]@{Computer=$env:COMPUTERNAME;VolumeCount=@($volumes).Count;ProtectedVolumes=@($volumes|Where-Object ProtectionStatus -eq 'On').Count;TpmPresent=$tpm.TpmPresent;TpmReady=$tpm.TpmReady;Generated=Get-Date}
$volumes|Export-Csv (Join-Path $OutputPath "bitlocker_volumes_$stamp.csv") -NoTypeInformation -Encoding UTF8
$tpm|Export-Csv (Join-Path $OutputPath "tpm_status_$stamp.csv") -NoTypeInformation -Encoding UTF8
@{Summary=$summary;Volumes=$volumes;TPM=$tpm}|ConvertTo-Json -Depth 6|Set-Content (Join-Path $OutputPath "bitlocker_readiness_$stamp.json") -Encoding UTF8
$html="<h1>BitLocker Recovery Readiness - $env:COMPUTERNAME</h1><p>Generated $(Get-Date)</p><h2>Summary</h2>$(@($summary)|ConvertTo-Html -Fragment)<h2>Volumes</h2>$($volumes|ConvertTo-Html -Fragment)<h2>TPM</h2>$(@($tpm)|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'BitLocker Recovery Readiness'|Set-Content (Join-Path $OutputPath "bitlocker_readiness_$stamp.html") -Encoding UTF8
$summary|Format-List
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
