#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="$REPO_ROOT/install.sh"
UNINSTALL="$REPO_ROOT/uninstall.sh"

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

TMPROOT="$(mktemp -d)"
trap 'rm -rf "$TMPROOT"' EXIT

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1" >&2; exit 1; }

fresh_home() {
  local d
  d="$(mktemp -d -p "$TMPROOT")"
  echo "$d"
}

# ---------- Test 1: default install creates 10 symlinks ----------
H="$(fresh_home)"
HOME="$H" "$INSTALL" >/dev/null
target="$H/.claude/skills"
for s in "${SKILLS[@]}"; do
  [ -L "$target/$s" ] || fail "default install: $s is not a symlink"
  resolved="$(readlink -f "$target/$s")"
  expected="$(readlink -f "$REPO_ROOT/$s")"
  [ "$resolved" = "$expected" ] || fail "default install: $s resolves to $resolved, expected $expected"
done
count=$(find "$target" -mindepth 1 -maxdepth 1 -type l | wc -l)
[ "$count" -eq 10 ] || fail "default install: found $count symlinks, expected 10"
pass "default install creates 10 symlinks"

# ---------- Test 2: collision refusal ----------
if HOME="$H" "$INSTALL" >/dev/null 2>&1; then
  fail "second install should have failed but exited 0"
fi
# verify nothing was disturbed: still 10 symlinks, no extras
count=$(find "$target" -mindepth 1 -maxdepth 1 | wc -l)
[ "$count" -eq 10 ] || fail "collision refusal: target has $count entries, expected 10"
pass "collision refusal"

# ---------- Test 3: --copy install ----------
H="$(fresh_home)"
HOME="$H" "$INSTALL" --copy >/dev/null
target="$H/.claude/skills"
for s in "${SKILLS[@]}"; do
  [ -d "$target/$s" ] || fail "--copy install: $s missing"
  [ -L "$target/$s" ] && fail "--copy install: $s is a symlink, expected real dir"
  [ -f "$target/$s/SKILL.md" ] || fail "--copy install: $s/SKILL.md missing"
done
pass "--copy install produces real directories"

# ---------- Test 4: --project install ----------
H="$(fresh_home)"
WD="$(mktemp -d -p "$TMPROOT")"
( cd "$WD" && HOME="$H" "$INSTALL" --project >/dev/null )
target="$WD/.claude/skills"
for s in "${SKILLS[@]}"; do
  [ -L "$target/$s" ] || fail "--project install: $s is not a symlink at $target"
done
[ ! -d "$H/.claude/skills" ] || fail "--project install: should not have created $H/.claude/skills"
pass "--project install lands in cwd"

# ---------- Test 5: uninstall removes symlinks ----------
H="$(fresh_home)"
HOME="$H" "$INSTALL" >/dev/null
HOME="$H" "$UNINSTALL" >/dev/null
target="$H/.claude/skills"
for s in "${SKILLS[@]}"; do
  [ ! -e "$target/$s" ] && [ ! -L "$target/$s" ] || fail "uninstall: $s still present"
done
# repo dirs untouched
for s in "${SKILLS[@]}"; do
  [ -d "$REPO_ROOT/$s" ] || fail "uninstall: repo dir $s was clobbered"
  [ -f "$REPO_ROOT/$s/SKILL.md" ] || fail "uninstall: $s/SKILL.md was clobbered"
done
pass "uninstall removes symlinks, repo intact"

# ---------- Test 6: uninstall preserves --copy installs ----------
H="$(fresh_home)"
HOME="$H" "$INSTALL" --copy >/dev/null
HOME="$H" "$UNINSTALL" >/dev/null
target="$H/.claude/skills"
for s in "${SKILLS[@]}"; do
  [ -d "$target/$s" ] || fail "uninstall --copy: $s should have been preserved"
  [ -f "$target/$s/SKILL.md" ] || fail "uninstall --copy: $s/SKILL.md missing"
done
pass "uninstall preserves --copy installs"

# ---------- Test 7: install -> uninstall -> install cycle ----------
H="$(fresh_home)"
HOME="$H" "$INSTALL" >/dev/null
HOME="$H" "$UNINSTALL" >/dev/null
HOME="$H" "$INSTALL" >/dev/null
target="$H/.claude/skills"
count=$(find "$target" -mindepth 1 -maxdepth 1 -type l | wc -l)
[ "$count" -eq 10 ] || fail "install/uninstall/install: found $count symlinks, expected 10"
pass "install -> uninstall -> install cycle"

# ---------- Test 8: --help exits 0 ----------
"$INSTALL" --help >/dev/null
"$UNINSTALL" --help >/dev/null
pass "--help exits 0"

echo
echo "All tests passed."
