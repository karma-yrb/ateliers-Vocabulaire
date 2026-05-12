[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Path)) {
  throw "File not found: $Path"
}

$fullPath = (Resolve-Path -LiteralPath $Path).Path
$backupPath = "$fullPath.bak_before_fix"

Copy-Item -LiteralPath $fullPath -Destination $backupPath -Force

$raw = [System.IO.File]::ReadAllText($fullPath, [System.Text.Encoding]::UTF8)
$enc1252 = [System.Text.Encoding]::GetEncoding(1252)
$fixed = [System.Text.Encoding]::UTF8.GetString($enc1252.GetBytes($raw))

$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($fullPath, $fixed, $utf8Bom)

Write-Host "Fixed mojibake in: $fullPath"
Write-Host "Backup created: $backupPath"

