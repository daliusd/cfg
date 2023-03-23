#!/bin/sh

set - # "set -e" is default and if diff tools returns non 0 exit code then git produces "fatal: external diff died"

bn="$(basename "$1")"

if [[ -z "$GIT_DIFF_IMAGE_ENABLED" ]]; then
  echo "Diffing disabled for \"$bn\". Use 'git diff-image' to see image diffs."
else
  echo "Diffing ${bn}"
  destfile="$(mktemp -t "$bn").png"
  odiff "$1" "$2" "$destfile"
  open "$destfile"
fi
