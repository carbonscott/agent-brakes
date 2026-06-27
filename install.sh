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
)

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

mode="symlink"
target=""
project=0

usage() {
  cat <<EOF
Usage: $0 [--copy] [--project] [--target=<dir>] [--help]

Installs brake skills into a Claude Code skills directory.

Options:
  --copy           Copy skill directories instead of symlinking them.
  --project        Install into \$(pwd)/.claude/skills instead of \$HOME/.claude/skills.
  --target=<dir>   Install into <dir> explicitly. Overrides --project.
  -h, --help       Show this message.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --copy) mode="copy" ;;
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

collisions=()
for s in "${SKILLS[@]}"; do
  if [ -e "$target/$s" ] || [ -L "$target/$s" ]; then
    collisions+=("$target/$s")
  fi
done

if [ "${#collisions[@]}" -gt 0 ]; then
  echo "Refusing to install: the following paths already exist:" >&2
  for c in "${collisions[@]}"; do
    echo "  $c" >&2
  done
  echo "Remove or rename them and re-run." >&2
  exit 1
fi

mkdir -p "$target"

for s in "${SKILLS[@]}"; do
  if [ "$mode" = "copy" ]; then
    cp -r "$REPO_ROOT/$s" "$target/$s"
  else
    ln -s "$REPO_ROOT/$s" "$target/$s"
  fi
done

echo "Installed ${#SKILLS[@]} brake skills to $target (mode: $mode)"
