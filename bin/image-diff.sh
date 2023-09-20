#!/bin/sh

set - # "set -e" is default and if diff tools returns non 0 exit code then git produces "fatal: external diff died"

bn="$(basename "$1")"

if [[ -z "$GIT_DIFF_IMAGE_ENABLED" ]]; then
  echo "Diffing disabled for \"$bn\". Use 'git diff-image' to see image diffs."
else
  echo "Diffing $1"
  if [[ "$2" != "/dev/null" ]]; then
    diff="$(mktemp -t "$bn.XXXXXXX").png"
    gm compare -highlight-style assign -highlight-color red -file "$diff" "$1" "$2"

    # ALTERNATIVE WAY where we combine images
    # final="$(mktemp -t "$bn").png"
    # w=$(gm identify -format "%w" "$2")
    # h=$(gm identify -format "%h" "$2")
    # if ((w > h)); then
    #   gm convert "$2" "$1" +append "$final"
    #   gm convert "$final" "$diff" -append "$final"
    # else
    #   gm convert "$2" "$diff" "$1" +append "$final"
    # fi
    # # resize large diffs
    # gm mogrify -resize 2800x\> "$final"

    img2sixel "$diff"
    echo "Old:"
    img2sixel "$2"
  fi

  echo "New:"
  img2sixel "$1"

fi
