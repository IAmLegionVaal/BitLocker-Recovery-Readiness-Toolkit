# BitLocker Recovery Readiness Toolkit

A read-only PowerShell toolkit for BitLocker protection and recovery-readiness reporting.

## Features

- Volume protection status
- Encryption method and percentage
- TPM presence and readiness
- Recovery protector type summary
- CSV, JSON, and HTML reports

## Run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\BitLocker_Recovery_Readiness_Toolkit.ps1
```

## Safety

Read-only reporting only. No BitLocker or TPM settings are changed.
