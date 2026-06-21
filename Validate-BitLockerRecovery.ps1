#requires -Version 5.1
<# Created by Dewald Pretorius. Read-only BitLocker recovery readiness validator. #>
[CmdletBinding()]
param([string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'BitLocker_Recovery_Validation'))
$ErrorActionPreference='Stop';New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null;$stamp=Get-Date -Format yyyyMMdd_HHmmss
try{
 $volumes=@(Get-BitLockerVolume|ForEach-Object{$recovery=@($_.KeyProtector|Where-Object KeyProtectorType -eq 'RecoveryPassword');[pscustomobject]@{MountPoint=$_.MountPoint;VolumeStatus=$_.VolumeStatus;ProtectionStatus=$_.ProtectionStatus;EncryptionMethod=$_.EncryptionMethod;RecoveryProtectorCount=$recovery.Count;Ready=($_.ProtectionStatus-eq'On'-and$recovery.Count-gt 0)}})
 $volumes|Export-Csv -LiteralPath (Join-Path $OutputPath "bitlocker_readiness_$stamp.csv") -NoTypeInformation -Encoding UTF8
 [ordered]@{Generated=(Get-Date);Volumes=$volumes;NotReadyCount=@($volumes|Where-Object{-not $_.Ready}).Count}|ConvertTo-Json -Depth 5|Set-Content -LiteralPath (Join-Path $OutputPath "bitlocker_readiness_$stamp.json") -Encoding UTF8
 if(@($volumes|Where-Object{-not $_.Ready}).Count){exit 1};exit 0
}catch{Write-Error $_.Exception.Message;exit 5}
