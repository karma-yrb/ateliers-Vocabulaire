param(
  [Parameter(Position = 0)]
  [ValidateSet("pub")]
  [string]$Action = "pub",

  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Args
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

switch ($Action) {
  "pub" {
    $releaseScript = Join-Path $PSScriptRoot "Release-Auto.ps1"
    & $releaseScript @Args
  }
}
