function inotify-status --description 'Show inotify instances and watches usage'
    set -l max_instances (cat /proc/sys/fs/inotify/max_user_instances)
    set -l max_watches (cat /proc/sys/fs/inotify/max_user_watches)
    
    # Count total instances
    set -l total_instances (find /proc/*/fd -lname anon_inode:inotify 2>/dev/null | wc -l)
    
    # Calculate total watches and collect process info
    set -l total_watches 0
    set -l watch_data
    
    for foo in /proc/*/fd/*
        if test -L "$foo"
            set -l link (readlink "$foo" 2>/dev/null)
            if string match -q "anon_inode:inotify" -- "$link"
                set -l pid (string split '/' $foo)[3]
                set -l fd (string split '/' $foo)[5]
                
                if test -f "/proc/$pid/fdinfo/$fd"
                    set -l watches (grep -c "^inotify" "/proc/$pid/fdinfo/$fd" 2>/dev/null | head -1; or echo 0)
                    set total_watches (math "$total_watches + $watches")
                    
                    if test "$watches" -gt 0
                        # Get command name
                        set -l cmd (ps -p $pid -o comm= 2>/dev/null; or echo "unknown")
                        
                        # Get parent process info - trace up to find first non-interpreter parent
                        set -l ppid (ps -p $pid -o ppid= 2>/dev/null | string trim)
                        set -l parent_cmd ""
                        if test -n "$ppid" -a "$ppid" != "0"
                            set parent_cmd (ps -p $ppid -o comm= 2>/dev/null; or echo "")
                            
                            # Keep going up the parent chain if parent is a generic interpreter or language server wrapper
                            while test -n "$parent_cmd" -a "$ppid" != "0" -a "$ppid" != "1"
                                # Stop if we found a meaningful parent (not node, python, language servers, etc.)
                                if not string match -qr '^(node|python|python3|ruby|perl|bash|sh|fish|typescript-lang.*|lua-language-se.*|rust-analyzer|gopls|jdtls)$' -- "$parent_cmd"
                                    break
                                end
                                set ppid (ps -p $ppid -o ppid= 2>/dev/null | string trim)
                                if test -n "$ppid" -a "$ppid" != "0"
                                    set parent_cmd (ps -p $ppid -o comm= 2>/dev/null; or echo "")
                                else
                                    break
                                end
                            end
                        end
                        
                        # Try to get better command name from cmdline (e.g., tsserver instead of node)
                        set -l cmdline_file "/proc/$pid/cmdline"
                        if test -f "$cmdline_file"
                            set -l cmdline (tr "\0" " " < "$cmdline_file")
                            # Check if it's a node/python/etc process running a specific script
                            if string match -q "*node*" -- "$cmdline"
                                # Look for common language servers and tools
                                if string match -q "*tsserver.js*" -- "$cmdline"
                                    set cmd "tsserver"
                                else if string match -q "*typescript-language-server*" -- "$cmdline"
                                    set cmd "typescript-ls"
                                else if string match -q "*vscode-eslint-language-server*" -- "$cmdline"
                                    set cmd "eslint-ls"
                                else if string match -q "*eslint*" -- "$cmdline"
                                    set cmd "eslint"
                                else if string match -q "*prettier*" -- "$cmdline"
                                    set cmd "prettier"
                                else if string match -q "*vue-language-server*" -- "$cmdline"
                                    set cmd "vue-ls"
                                end
                            else if string match -q "*python*" -- "$cmdline"
                                # Extract script name for python processes
                                if string match -q "*pylsp*" -- "$cmdline"
                                    set cmd "pylsp"
                                else if string match -q "*pyright*" -- "$cmdline"
                                    set cmd "pyright"
                                end
                            end
                        end
                        
                        # Build display string with parent process if available
                        if test -n "$parent_cmd"
                            set -a watch_data "$watches|$pid|$cmd ($parent_cmd)"
                        else
                            set -a watch_data "$watches|$pid|$cmd"
                        end
                    end
                end
            end
        end
    end
    
    # Calculate percentages
    set -l instances_pct (math "($total_instances / $max_instances) * 100")
    set -l watches_pct (math "($total_watches / $max_watches) * 100")
    
    # Choose color based on usage
    set -l instances_color (set_color normal)
    set -l watches_color (set_color normal)
    
    if test $instances_pct -ge 80
        set instances_color (set_color red)
    else if test $instances_pct -ge 50
        set instances_color (set_color yellow)
    else
        set instances_color (set_color green)
    end
    
    if test $watches_pct -ge 80
        set watches_color (set_color red)
    else if test $watches_pct -ge 50
        set watches_color (set_color yellow)
    else
        set watches_color (set_color green)
    end
    
    # Display summary
    echo ""
    echo (set_color --bold)"Inotify Status:"(set_color normal)
    printf "  Instances: %s%d / %d (%.2f%%)%s\n" "$instances_color" $total_instances $max_instances $instances_pct (set_color normal)
    printf "  Watches:   %s%d / %d (%.2f%%)%s\n" "$watches_color" $total_watches $max_watches $watches_pct (set_color normal)
    echo ""
    
    # Sort and display top watchers
    echo (set_color --bold)"Top 15 Processes by Watch Count:"(set_color normal)
    printf "%-10s %-8s %s\n" "WATCHES" "PID" "COMMAND"
    printf "%s\n" $watch_data | sort -t'|' -k1 -rn | head -15 | while read -l line
        set -l parts (string split '|' $line)
        printf "%-10s %-8s %s\n" $parts[1] $parts[2] $parts[3]
    end
    echo ""
end
