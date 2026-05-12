[CmdletBinding()]
param(
  [string]$Root = ".",
  [string[]]$Include = @("*.html", "*.htm", "*.js", "*.css")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-TargetFiles {
  param(
    [string]$BasePath,
    [string[]]$Patterns
  )

  Get-ChildItem -Path $BasePath -Recurse -File | Where-Object {
    $name = $_.Name.ToLowerInvariant()
    foreach ($pattern in $Patterns) {
      if ($name -like $pattern.ToLowerInvariant()) { return $true }
    }
    return $false
  }
}

function Get-MojibakeMarkers {
  return @(
    [string][char]0x00C3,                  # "A-tilde" marker from broken UTF-8
    [string][char]0x00C2,                  # "A-circumflex" marker from broken UTF-8
    ([string][char]0x00E2 + [char]0x20AC), # "a-circumflex + euro" starts many broken sequences
    ([string][char]0x00F0 + [char]0x0178), # "eth + Y-diaeresis" starts broken emoji "ðŸ"
    [string][char]0xFFFD                   # replacement char
  )
}

$strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)
$markers = Get-MojibakeMarkers
$issues = @()

$files = Get-TargetFiles -BasePath $Root -Patterns $Include
if (-not $files) {
  Write-Host "No files found for include patterns."
  exit 0
}

foreach ($file in $files) {
  $path = $file.FullName
  $rawBytes = [System.IO.File]::ReadAllBytes($path)

  try {
    [void]$strictUtf8.GetString($rawBytes)
  }
  catch {
    $issues += "INVALID UTF-8 bytes: $path"
    continue
  }

  $text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

  if ($path.ToLowerInvariant().EndsWith(".html") -or $path.ToLowerInvariant().EndsWith(".htm")) {
    if ($text -notmatch '<meta\s+charset\s*=\s*["'']utf-8["'']') {
      $issues += "Missing <meta charset=""utf-8"">: $path"
    }
  }

  foreach ($marker in $markers) {
    if ($text.Contains($marker)) {
      $hits = Select-String -Path $path -SimpleMatch -Pattern $marker
      foreach ($hit in $hits | Select-Object -First 5) {
        $issues += "Mojibake marker found in ${path}:$($hit.LineNumber)"
      }
      break
    }
  }
}

if ($issues.Count -gt 0) {
  Write-Host ""
  Write-Host "Encoding check failed:"
  $issues | ForEach-Object { Write-Host " - $_" }
  Write-Host ""
  Write-Host "Tip: run .\scripts\Fix-Mojibake.ps1 -Path <file> before publishing."
  exit 1
}

Write-Host "Encoding check passed."
exit 0

