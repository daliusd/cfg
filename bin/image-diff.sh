#!/bin/bash

set - # "set -e" is default and if diff tools returns non 0 exit code then git produces "fatal: external diff died"

bn="$(basename "$1")"

is_webp() {
  [[ -f "$1" ]] && [[ "$(head -c 12 "$1" | tail -c 4)" == "WEBP" ]]
}

# Convert WebP to a temporary PNG (gm and imgcat may lack WebP support).
# Prints the path to use: the PNG if converted, otherwise the original file.
to_png() {
  if ! is_webp "$1"; then
    echo "$1"
    return
  fi
  local out
  out="$(mktemp -t "$(basename "$1").XXXXXXX").png"
  if command -v dwebp >/dev/null; then
    dwebp -quiet "$1" -o "$out"
  elif command -v magick >/dev/null; then
    magick "$1" "$out"
  else
    sips -s format png "$1" --out "$out" >/dev/null
  fi
  echo "$out"
}

# Git diff driver args: path old-file old-hex old-mode new-file new-hex new-mode
old="$2"
new="$5"

if [[ -z "$GIT_DIFF_IMAGE_ENABLED" ]]; then
  echo "Diffing disabled for \"$bn\". Use 'git diff-image' to see image diffs."
else
  echo "Diffing $1"
  [[ "$old" != "/dev/null" ]] && old="$(to_png "$old")"
  [[ "$new" != "/dev/null" ]] && new="$(to_png "$new")"

  if [[ "$new" == "/dev/null" ]]; then
    echo "File deleted: $bn"
  elif [[ "$old" != "/dev/null" ]]; then
    diff="$(mktemp -t "$bn.XXXXXXX").png"
    gm compare -highlight-style assign -highlight-color red -file "$diff" "$new" "$old"

    # ALTERNATIVE WAY where we combine images
    # final="$(mktemp -t "$bn").png"
    # w=$(gm identify -format "%w" "$old")
    # h=$(gm identify -format "%h" "$old")
    # if ((w > h)); then
    #   gm convert "$old" "$new" +append "$final"
    #   gm convert "$final" "$diff" -append "$final"
    # else
    #   gm convert "$old" "$diff" "$new" +append "$final"
    # fi
    # # resize large diffs
    # gm mogrify -resize 2800x\> "$final"

    wezterm imgcat "$diff"

    if [[ "$GIT_DIFF_IMAGE_ENABLED" == "1" ]]; then
      echo "Old:"
      wezterm imgcat "$old"
      echo "New:"
      wezterm imgcat "$new"
    fi
  else
    echo "New:"
    wezterm imgcat "$new"
  fi
fi
