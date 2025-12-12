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
                        set -l cmd (ps -p $pid -o comm= 2>/dev/null; or echo "unknown")
                        set -a watch_data "$watches|$pid|$cmd"
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
