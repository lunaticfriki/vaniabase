#!/usr/bin/env bash
set -eu

MESSAGE_FILE="${1:-}"
SOURCE="${2:-}"

if [ -z "$MESSAGE_FILE" ]; then
  exit 0
fi

case "$SOURCE" in
  message|merge|squash|commit)
    exit 0
    ;;
esac

if [ ! -t 0 ]; then
  exit 0
fi

TYPES=(
  "feat:a new feature"
  "fix:a bug fix"
  "docs:documentation only"
  "style:formatting, no code meaning change"
  "refactor:neither fixes a bug nor adds a feature"
  "perf:performance improvement"
  "test:adding or correcting tests"
  "build:build system or dependency changes"
  "ci:CI configuration changes"
  "chore:anything else"
  "revert:reverts a previous commit"
)

LABELS=()
for entry in "${TYPES[@]}"; do
  LABELS+=("${entry%%:*} - ${entry#*:}")
done

echo "Select the type of change:"
PS3="Type (number): "
select LABEL in "${LABELS[@]}"; do
  if [ -n "${LABEL:-}" ]; then
    TYPE="${TYPES[$((REPLY - 1))]%%:*}"
    break
  fi
  echo "Invalid selection."
done

read -r -p "Scope (optional, press enter to skip): " SCOPE
read -r -p "Short description: " DESCRIPTION

if [ -z "$DESCRIPTION" ]; then
  echo "Description cannot be empty. Commit aborted." >&2
  exit 1
fi

if [ -n "$SCOPE" ]; then
  HEADER="${TYPE}(${SCOPE}): ${DESCRIPTION}"
else
  HEADER="${TYPE}: ${DESCRIPTION}"
fi

echo "$HEADER" > "$MESSAGE_FILE"
