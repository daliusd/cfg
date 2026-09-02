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

fish_add_path -P ~/.local/opt/ruby/bin

if type -q ruby
  fish_add_path -P (ruby -e 'print Gem.user_dir')/bin
end

# Remove inherited and old universal Homebrew paths during migration.
set -l clean_path
for dir in $PATH
  if not string match -q '*linuxbrew*' $dir; and \
     not string match -q '*/Homebrew/*' $dir; and \
     not string match -q '/usr/local/opt/*' $dir
    set -a clean_path $dir
  end
end
set -gx PATH $clean_path

set -l clean_user_paths
for dir in $fish_user_paths
  if not string match -q '*linuxbrew*' $dir; and \
     not string match -q '*/Homebrew/*' $dir; and \
     not string match -q '/usr/local/opt/*' $dir
    set -a clean_user_paths $dir
  end
end
set -l old_user_paths (string join \x1e $fish_user_paths)
set -l new_user_paths (string join \x1e $clean_user_paths)
if test "$old_user_paths" != "$new_user_paths"
  set -U fish_user_paths $clean_user_paths
end

# User-space upstream installs take precedence over old system/Brew binaries.
fish_add_path -mP ~/.local/bin ~/bin
fish_add_path -P ~/.cargo/bin
fish_add_path -P ~/.bun/bin
fish_add_path -P ~/go/bin

alias ls='eza'
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
alias npmprivate='npm config set registry https://npm.dev.wixpress.com && npm config get registry'

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
alias gbp='git fetch --prune && git branch -vv | grep ": gone]" | awk "{print \$1}" | xargs -r git branch -D'

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

if type -q starship
  starship init fish | source
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
      set -x DOCKER_HOST unix://$HOME/.colima/default/docker.sock
end

if type -q fzf
  fzf --fish | source
end

switch (uname)
    case Linux
      if type -q codex
        codex completion fish | source
      end
end

if test -f "$HOME/.bazelenv.fish"
    source "$HOME/.bazelenv.fish"
end
