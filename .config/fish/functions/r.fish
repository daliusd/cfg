function r
  if test -e package.json
      set scripts (cat package.json | jq -r '.scripts | to_entries[] | [.key, .value] | @tsv' | fzf --height 40%)

      if test -n "$scripts"
          set script_name (echo "$scripts" | awk -F '\t' '{print $1}')
          commandline -it -- 'npm run '
          commandline -it -- $script_name
          commandline -it -- ' '
          commandline -f repaint
      else
          echo "Exit: You haven't selected any script"
        end
  else
      echo "Error: There's no package.json"
  end
end
