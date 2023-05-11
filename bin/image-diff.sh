#!/bin/sh

set - # "set -e" is default and if diff tools returns non 0 exit code then git produces "fatal: external diff died"

bn="$(basename "$1")"

if [[ -z "$GIT_DIFF_IMAGE_ENABLED" ]]; then
  echo "Diffing disabled for \"$bn\". Use 'git diff-image' to see image diffs."
else
  echo "Diffing ${bn}"
  diff="$(mktemp -t "$bn").png"
  final="$(mktemp -t "$bn").png"
  gm compare -highlight-style assign -highlight-color red -file "$diff" "$1" "$2"
  gm convert "$2" "$1" +append "$final"
  gm convert "$final" "$diff" -append "$final"
  open "$final"
fi
