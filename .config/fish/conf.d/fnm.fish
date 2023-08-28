set fnmpath (which fnm)
if set -q fnmpath
  fnm env --use-on-cd | source
end
