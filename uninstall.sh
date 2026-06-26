#!/usr/bin/env bash
set -euo pipefail

SKILLS=(
  no-eager
  clarify
  align
  breakdown
  approval
  formalize-plan
  formalize-plan-delegated
  no-op
  handoff
  latent-demand
  make-goal
)

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

target=""
project=0

usage() {
  cat <<EOF
Usage: $0 [--project] [--target=<dir>] [--help]

Removes brake skill symlinks that point into this repo.
Plain directories (e.g. installed via --copy) and symlinks pointing
elsewhere are left untouched and reported as skipped.

Options:
  --project        Uninstall from \$(pwd)/.claude/skills instead of \$HOME/.claude/skills.
  --target=<dir>   Uninstall from <dir> explicitly. Overrides --project.
  -h, --help       Show this message.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --project) project=1 ;;
    --target=*) target="${arg#--target=}" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

if [ -z "$target" ]; then
  if [ "$project" -eq 1 ]; then
    target="$(pwd)/.claude/skills"
  else
    target="$HOME/.claude/skills"
  fi
fi

removed=0
skipped=()

for s in "${SKILLS[@]}"; do
  path="$target/$s"
  if [ ! -e "$path" ] && [ ! -L "$path" ]; then
    continue
  fi
  if [ -L "$path" ]; then
    resolved="$(readlink -f "$path" || true)"
    expected="$REPO_ROOT/$s"
    expected_resolved="$(readlink -f "$expected" || true)"
    if [ -n "$resolved" ] && [ "$resolved" = "$expected_resolved" ]; then
      rm "$path"
      removed=$((removed + 1))
    else
      skipped+=("$path (symlink points to $resolved, not this repo)")
    fi
  else
    skipped+=("$path (plain directory; remove manually if it was --copy installed)")
  fi
done

echo "Removed $removed symlinks"
if [ "${#skipped[@]}" -gt 0 ]; then
  echo "Skipped:"
  for s in "${skipped[@]}"; do
    echo "  $s"
  done
fi
