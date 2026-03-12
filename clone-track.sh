#!/bin/bash
# ─────────────────────────────────────────────
# Instruqt Track Cloner
# Clones the M.A.R.S track for a new event.
# Usage: ./clone-track.sh
# Requires: instruqt CLI authenticated to newrelic org
# ─────────────────────────────────────────────

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
ORG="newrelic"
TARGET_DIR=""  # set after input, used by cleanup trap

print_step() { echo -e "\n\033[1;36m▶ $1\033[0m"; }
print_ok()   { echo -e "\033[1;32m✔ $1\033[0m"; }
print_err()  { echo -e "\033[1;31m✖ $1\033[0m" >&2; }
print_cmd()  { echo -e "\033[1;33m  $ $1\033[0m"; }
print_warn() { echo -e "\033[1;33m⚠ $1\033[0m"; }

# ── Cleanup on unexpected exit ─────────────────
cleanup() {
  local exit_code=$?
  if [[ $exit_code -ne 0 && -n "$TARGET_DIR" && -d "$TARGET_DIR" ]]; then
    print_warn "Script failed — removing partially created folder: $TARGET_DIR"
    rm -rf "$TARGET_DIR"
  fi
}
trap cleanup EXIT

# ── Prereq check ──────────────────────────────
if ! command -v instruqt &>/dev/null; then
  print_err "instruqt CLI not found. See: https://docs.instruqt.com/reference/instruqt-cli"
  exit 1
fi

# ── Inputs ────────────────────────────────────
# mars-program is the original production track — used as the cloning source
SOURCE_TRACK="mars-program"

print_step "Instruqt Track Cloner  [org: $ORG]"
echo "Working directory: $BASE_DIR"
echo "Source track: $SOURCE_TRACK"
echo ""

# Suffix = event identifier, e.g. 'mirae-pilot' → new track: mars-program-mirae-pilot
read -rp "Event name suffix (e.g. mirae-pilot, acme-workshop): " EVENT_SUFFIX
[[ -z "$EVENT_SUFFIX" ]] && { print_err "Event name suffix required."; exit 1; }

NEW_TRACK="${SOURCE_TRACK}-${EVENT_SUFFIX}"

# Validate slug format: lowercase, numbers, hyphens only
if [[ ! "$NEW_TRACK" =~ ^[a-z0-9-]+$ ]]; then
  print_err "Derived track name '$NEW_TRACK' is invalid. Use only lowercase letters, numbers, and hyphens in the event suffix."
  exit 1
fi

echo ""
echo -e "  New track name: \033[1;32m$NEW_TRACK\033[0m"

TARGET_DIR="$BASE_DIR/$NEW_TRACK"

if [[ -d "$TARGET_DIR" ]]; then
  print_err "Folder '$NEW_TRACK' already exists in $BASE_DIR. Pick a different event suffix or remove it first."
  exit 1
fi

# ── Pull ──────────────────────────────────────
print_step "Pulling: $SOURCE_TRACK"
print_cmd "cd $BASE_DIR/$SOURCE_TRACK"
cd "$BASE_DIR/$SOURCE_TRACK"

print_cmd "instruqt track pull"
instruqt track pull

print_cmd "cp -r $BASE_DIR/$SOURCE_TRACK $TARGET_DIR"
cp -r "$BASE_DIR/$SOURCE_TRACK" "$TARGET_DIR"
print_ok "Pulled and copied to: $TARGET_DIR"

# ── Update track.yml ──────────────────────────
TRACK_YML="$TARGET_DIR/track.yml"
[[ ! -f "$TRACK_YML" ]] && { print_err "track.yml not found in $TARGET_DIR."; exit 1; }

print_step "Updating track.yml"

print_cmd "sed slug -> $NEW_TRACK in track.yml"
sed -i.bak "s|^slug:.*|slug: $NEW_TRACK|" "$TRACK_YML"
rm -f "$TRACK_YML.bak"
print_ok "Slug set to: $NEW_TRACK"

# Derive title: existing title + suffix in Title Case (auto-applied, no prompt)
EXISTING_TITLE=$(grep '^title:' "$TRACK_YML" | sed 's/^title:[[:space:]]*//' | tr -d '"')
SUFFIX_TITLE=$(echo "$EVENT_SUFFIX" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')
NEW_TITLE="$EXISTING_TITLE $SUFFIX_TITLE"
print_cmd "sed title -> \"$NEW_TITLE\" in track.yml"
sed -i.bak "s|^title:.*|title: \"$NEW_TITLE\"|" "$TRACK_YML"
rm -f "$TRACK_YML.bak"
print_ok "Title set to: $NEW_TITLE"

# ── Validate ──────────────────────────────────
print_step "Validating"
print_cmd "cd $TARGET_DIR"
cd "$TARGET_DIR"

print_cmd "instruqt track validate"
instruqt track validate
print_ok "Validation passed"

# ── Push ──────────────────────────────────────
# Disable trap before push — folder is valid at this point
trap - EXIT

read -rp "Push track now? (y/N): " CONFIRM_PUSH
if [[ "$CONFIRM_PUSH" =~ ^[Yy]$ ]]; then
  print_step "Pushing: $NEW_TRACK"
  print_cmd "instruqt track push"
  instruqt track push
  print_ok "Track live:"
  echo -e "  \033[1;32mhttps://play.instruqt.com/manage/$ORG/tracks/$NEW_TRACK\033[0m"
else
  echo ""
  print_warn "Push skipped. Track has not been published yet."
  echo "Review the track files locally before pushing:"
  print_cmd "cd $TARGET_DIR && instruqt track push"
fi

echo ""
print_step "Done"
echo "  Folder : $TARGET_DIR"
echo "  Slug   : $NEW_TRACK"
echo "  Title  : $NEW_TITLE"
