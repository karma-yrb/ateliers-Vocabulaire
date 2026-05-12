[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Running encoding checks..."
& "$PSScriptRoot\Test-Encoding.ps1" -Root (Resolve-Path "$PSScriptRoot\..").Path

Write-Host "Preflight OK."

