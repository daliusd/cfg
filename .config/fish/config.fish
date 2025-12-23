if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -Ux EDITOR nvim
set -Ux GPG_TTY tty

# Aliases

alias e=nvim

function cfg
  git --git-dir=$HOME/.cfg/ --work-tree=$HOME $argv
end

switch (uname)
    case Linux
        alias open='xdg-open'
    case Darwin
    case '*'
        echo Open config.fish and review it!
end

switch (uname)
    case Darwin
      fish_add_path -P /usr/local/opt/ruby/bin
      fish_add_path -P (gem environment gemdir)/bin
end

fish_add_path -P ~/bin
fish_add_path -P ~/.local/bin
fish_add_path -P ~/.npm-global/bin
fish_add_path -P ~/.cargo/bin
fish_add_path -P ~/.bun/bin

alias ls='lsd'
alias ll='ls -al'
alias lt='ls --tree'

alias gr=rg

alias snc='sync.sh'
alias uu='updateall.fish'

set username 'Dalius Dobravolskas'
set private_email 'dalius.dobravolskas@gmail.com'
set work_email 'daliusd@wix.com'

alias gitprivate='git config user.email "$private_email" && git config user.name "$username"'
alias gitwork='git config user.email "$work_email" && git config user.name "$username"'

alias gitprivateglobal='git config --global user.email "$private_email" && git config --global user.name "$username"'
alias gitworkglobal='git config --global user.email "$work_email" && git config --global user.name "$username"'
alias cdr='cd (git root)'
alias cdp='cd ~/projects'

alias brfr='xdg-settings set default-web-browser firefox.desktop'
alias brch='xdg-settings set default-web-browser google-chrome.desktop'
alias kben='gsettings set org.gnome.desktop.input-sources sources "[(\'xkb\', \'us\')]"'
alias kblt='gsettings set org.gnome.desktop.input-sources sources "[(\'xkb\', \'us\'), (\'xkb\', \'lt\')]"'

alias npmpublic='npm config set registry https://registry.npmjs.org/ && npm config get registry'
alias npmprivate='npm config set registry http://npm.dev.wixpress.com && npm config get registry'

alias ga='git add'
alias gb='git branch'
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gci='git commit'
alias gciv='git commit -v'
alias gco='git checkout'
alias gps='git push'
alias gpl='git pull'
alias gpls='git pull --rebase && gps'
alias gl='git lg'
alias glt='git lgt'
alias gsu='git ci -m "temp" && git stash && git reset --soft HEAD~1'
alias gbprune='git fetch --prune && git branch -vv | grep ": gone]" | awk "{print \$1}" | xargs -r git branch -D'

function gitsearch
    if test (count $argv) -eq 0
        echo "Usage: gitsearch <search_text>"
        return 1
    end
    
    git log -S "$argv" --oneline --color=always | \
        fzf --ansi \
            --preview 'git show --color=always {1}' \
            --preview-window=right:60%:wrap \
            --bind 'enter:execute(git show {1} | less -R)'
end

alias h='history --merge'

alias dnsflush='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

alias ai='gh models run openai/gpt-4.1-mini'

alias yolo='git push -u origin $(git branch --show-current); gh pr create --fill-first; gh pr comment -b "#skipreview"; gh pr merge --auto --squash'
alias rubber-stamp='git push -u origin $(git branch --show-current); gh pr create --fill-first; gh pr merge --auto --squash'
# FZF

set FZF_DEFAULT_COMMAND 'fd -t f'
set FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set FZF_ALT_C_COMMAND "fd -t d"
set FZF_DEFAULT_OPTS '--bind ctrl-d:page-down,ctrl-u:page-up'

# Starship

starship init fish | source


switch (uname)
    case Linux
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    case Darwin
        eval "$(/usr/local/bin/brew shellenv)"
    case '*'
        echo Open config.fish and review it!
end

# Volta

set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH

function __check_nvmrc --on-event fish_prompt --description 'check .nvmrc on pwd change and run volta install'
  status --is-command-substitution; and return

  set -l dir (pwd)

  while not test "$dir" = ''
    set nvmrc_file "$dir/.nvmrc"

    if test -e "$nvmrc_file"
      set nodeversion (cat $nvmrc_file)
      volta install node@$nodeversion --quiet
      break
    end

    set dir (string split -r -m1 / $dir)[1]
  end
end

switch (uname)
    case Darwin
      set -Ux OPENCODE_CONFIG ~/.config/opencode/config-personal.json
    case Linux
      set -Ux OPENCODE_CONFIG ~/.config/opencode/config-work.json
end

fzf --fish | source

# Bind F12 to wezterm word selector (triggered by WezTerm Alt+/)
bind \e\[24~ wezterm-fzf-words
bind -M insert \e\[24~ wezterm-fzf-words

