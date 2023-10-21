#!/usr/bin/env fish

if test -n "$argv[1]"
  and test -n "$argv[2]"
  ffmpeg -i "$argv[1]" -q:a 0 -map a "$argv[2]"
else
  echo 'tomp3 video output.mp3'
end
