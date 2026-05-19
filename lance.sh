#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-}"
if [[ $# -gt 0 ]]; then
  shift
fi

case "$ACTION" in
  pub)
    exec "$(cd "$(dirname "$0")" && pwd)/scripts/Release-Auto.sh" "$@"
    ;;
  "")
    echo "Usage: ./lance.sh pub -m \"message\" [--release-as patch|minor|major]"
    exit 1
    ;;
  *)
    echo "Unknown action: $ACTION"
    echo "Usage: ./lance.sh pub -m \"message\" [--release-as patch|minor|major]"
    exit 1
    ;;
esac
