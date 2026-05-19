#!/usr/bin/env bash
set -euo pipefail

COMMIT_MESSAGE=""
RELEASE_AS="patch"
REMOTE="origin"
BRANCH=""
FIRST_RELEASE="false"
SKIP_COMMIT="false"

usage() {
  echo "Usage: ./scripts/Release-Auto.sh -m \"commit message\" [--release-as patch|minor|major|prepatch|preminor|premajor|prerelease] [--remote origin] [--branch main] [--first-release] [--skip-commit]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--message|--commit-message)
      COMMIT_MESSAGE="${2:-}"
      shift 2
      ;;
    --release-as)
      RELEASE_AS="${2:-patch}"
      shift 2
      ;;
    --remote)
      REMOTE="${2:-origin}"
      shift 2
      ;;
    --branch)
      BRANCH="${2:-}"
      shift 2
      ;;
    --first-release)
      FIRST_RELEASE="true"
      shift
      ;;
    --skip-commit)
      SKIP_COMMIT="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if ! command -v git >/dev/null 2>&1; then
  echo "git is required."
  exit 1
fi

NPM_BIN=""
if command -v npm >/dev/null 2>&1; then
  NPM_BIN="npm"
elif command -v npm.cmd >/dev/null 2>&1; then
  NPM_BIN="npm.cmd"
else
  echo "npm is required (npm or npm.cmd)."
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if [[ -z "$BRANCH" ]]; then
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
fi

if [[ "$SKIP_COMMIT" != "true" ]]; then
  if [[ -z "$COMMIT_MESSAGE" ]]; then
    echo "Commit message is required unless --skip-commit is used."
    usage
    exit 1
  fi

  git add -A
  if [[ -n "$(git diff --cached --name-only)" ]]; then
    git commit -m "$COMMIT_MESSAGE"
    echo "Commit created: $COMMIT_MESSAGE"
  else
    echo "No staged changes to commit."
  fi
fi

if [[ ! -d "$REPO_ROOT/node_modules/standard-version" ]]; then
  echo "Installing npm dependencies..."
  "$NPM_BIN" install
fi

echo "Running standard-version..."
if [[ "$FIRST_RELEASE" == "true" ]]; then
  "$NPM_BIN" run release -- --first-release
else
  "$NPM_BIN" run release -- --release-as "$RELEASE_AS"
fi

echo "Pushing branch and tags to $REMOTE/$BRANCH..."
git push --follow-tags "$REMOTE" "$BRANCH"

echo "Release completed successfully."
