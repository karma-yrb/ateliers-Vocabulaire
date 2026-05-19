Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$startMarker = "# >>> PIMMS lance alias >>>"
$endMarker = "# <<< PIMMS lance alias <<<"

$block = @'
# >>> PIMMS lance alias >>>
function lance {
  param(
    [Parameter(Position = 0)]
    [string]$Action,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
  )

  if ([string]::IsNullOrWhiteSpace($Action)) {
    Write-Host "Usage: lance pub -CommitMessage \"message\" [-ReleaseAs patch|minor|major]"
    return
  }

  switch ($Action.ToLowerInvariant()) {
    "pub" {
      $repoRoot = ""
      try { $repoRoot = (git rev-parse --show-toplevel).Trim() } catch {}

      if ([string]::IsNullOrWhiteSpace($repoRoot)) {
        throw "Impossible de localiser le repo git courant. Lance la commande depuis le repo."
      }

      $scriptPath = Join-Path $repoRoot "scripts/Release-Auto.ps1"
      if (-not (Test-Path $scriptPath)) {
        throw "Script introuvable: $scriptPath"
      }

      & $scriptPath @Args
      return
    }

    default {
      throw "Action inconnue: '$Action'. Action supportée: pub"
    }
  }
}
# <<< PIMMS lance alias <<<
'@

$profilePath = $PROFILE
$profileDir = Split-Path -Parent $profilePath
if (-not (Test-Path $profileDir)) {
  New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
}
if (-not (Test-Path $profilePath)) {
  New-Item -Path $profilePath -ItemType File -Force | Out-Null
}

$content = Get-Content -Path $profilePath -Raw

if ($content -match [regex]::Escape($startMarker)) {
  $pattern = [regex]::Escape($startMarker) + ".*?" + [regex]::Escape($endMarker)
  $updated = [regex]::Replace($content, $pattern, $block, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  Set-Content -Path $profilePath -Value $updated -Encoding UTF8
} else {
  $separator = if ([string]::IsNullOrWhiteSpace($content)) { "" } else { "`r`n`r`n" }
  Set-Content -Path $profilePath -Value ($content + $separator + $block) -Encoding UTF8
}

. $PROFILE
Write-Host "Alias prêt: lance pub"
Write-Host "Exemple: lance pub -CommitMessage \"chore: release patch\" -ReleaseAs patch"
