function wezterm-fzf-words -d "Select words from scrollback using fzf"
    # Get the temp directory
    set tmpdir (set -q TMPDIR; and echo $TMPDIR; or echo "/tmp")

    # Get the pane ID from the WEZTERM_PANE environment variable
    set pane_id (set -q WEZTERM_PANE; and echo $WEZTERM_PANE; or echo "0")

    set WORDS_FILE "$tmpdir/wezterm-words-$pane_id.tmp"

    if not test -f "$WORDS_FILE"
        commandline -f repaint
        return 1
    end

    # Use fzf to select a word (max 10 lines height)
    set selected (cat "$WORDS_FILE" | fzf --reverse --height=10 < /dev/tty)

    if test -n "$selected"
        # Insert the selected word at cursor position
        commandline -i "$selected"
    end

    # Redraw the prompt
    commandline -f repaint
end
