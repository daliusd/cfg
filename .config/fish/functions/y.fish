function y
  if test -e package.json
      set scripts (cat package.json | jq -r '.scripts | to_entries[] | [.key, .value] | @tsv' | fzf --height 40%)

      if test -n "$scripts"
          set script_name (echo "$scripts" | awk -F '\t' '{print $1}')
          # Find the nearest package manager marker without leaving this repo.
          set -l dir "$PWD"
          set -l runner 'yarn '
          while true
            if test -e "$dir/package-lock.json"
              set runner 'npm run '
              break
            else if test -e "$dir/pnpm-lock.yaml"; or test -e "$dir/pnpm-workspace.yaml"
              set runner 'pnpm run '
              break
            else if test -e "$dir/yarn.lock"; or test -e "$dir/.git"; or test "$dir" = /
              break
            end
            set dir (path dirname -- "$dir")
          end
          commandline -it -- "$runner"
          commandline -it -- $script_name
          commandline -it -- ' '
          commandline -f repaint
      else
          echo "Exit: You haven't selected any script"
        end
  else if test -e Makefile -o -e makefile -o -e GNUmakefile
      set -l makefile
      for f in GNUmakefile makefile Makefile
        if test -e $f
          set makefile $f
          break
        end
      end

      # Targets, with the comment block right above them as the description.
      set targets (awk '
        /^[ \t]*#/ {
          line = $0
          sub(/^[ \t]*#[ \t]?/, "", line)
          desc = (desc == "" ? line : desc " " line)
          next
        }
        /^\.[A-Za-z]/ { desc = ""; next }
        /^[A-Za-z0-9_][A-Za-z0-9_.\/-]*[ \t]*:([^=]|$)/ {
          target = $0
          sub(/[ \t]*:.*$/, "", target)
          print target "\t" desc
          desc = ""
          next
        }
        { desc = "" }
      ' $makefile | fzf --height 40%)

      if test -n "$targets"
          set target_name (echo "$targets" | awk -F '\t' '{print $1}')
          commandline -it -- 'make '
          commandline -it -- $target_name
          commandline -it -- ' '
          commandline -f repaint
      else
          echo "Exit: You haven't selected any target"
      end
  else
      echo "Error: There's no package.json or Makefile"
  end
end
