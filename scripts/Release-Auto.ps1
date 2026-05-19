param(
  [Parameter(Mandatory = $true)]
  [string]$CommitMessage,

  [ValidateSet("patch", "minor", "major", "prepatch", "preminor", "premajor", "prerelease")]
  [string]$ReleaseAs = "patch",

  [string]$Remote = "origin",

  [string]$Branch = "",

  [switch]$FirstRelease,

  [switch]$SkipCommit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $repoRoot

try {
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git n'est pas disponible dans ce terminal."
  }

  if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
    throw "npm.cmd n'est pas disponible dans ce terminal."
  }

  if ([string]::IsNullOrWhiteSpace($Branch)) {
    $Branch = (git rev-parse --abbrev-ref HEAD).Trim()
  }

  if (-not $SkipCommit) {
    git add -A

    $stagedFiles = git diff --cached --name-only
    if ($stagedFiles) {
      git commit -m $CommitMessage
      Write-Host "Commit créé: $CommitMessage"
    } else {
      Write-Host "Aucun changement à committer."
    }
  } else {
    Write-Host "Commit ignoré (--SkipCommit)."
  }

  if (-not (Test-Path (Join-Path $repoRoot "node_modules\standard-version"))) {
    Write-Host "Installation des dépendances npm..."
    npm.cmd install
  }

  Write-Host "Lancement standard-version..."
  $releaseArgs = @("run", "release", "--")

  if ($FirstRelease) {
    $releaseArgs += "--first-release"
  } else {
    $releaseArgs += "--release-as"
    $releaseArgs += $ReleaseAs
  }

  & npm.cmd @releaseArgs

  Write-Host "Push branche + tags vers $Remote/$Branch..."
  git push --follow-tags $Remote $Branch

  Write-Host "Release terminée avec succès."
}
finally {
  Pop-Location
}
