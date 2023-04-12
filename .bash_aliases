alias e=nvim
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias cfg='git --git-dir=/Users/daliusd/.cfg/ --work-tree=/Users/daliusd'
else
    alias cfg='git --git-dir=/home/dalius/.cfg/ --work-tree=/home/dalius'
    alias open='xdg-open'
fi

alias ls='lsd'
alias ll='ls -al'
alias lt='ls --tree'

alias gr=rg

alias snc='sync.sh'

username='Dalius Dobravolskas'
private_email='dalius.dobravolskas@gmail.com'
work_email='daliusd@wix.com'

alias gitprivate='git config user.email "$private_email" && git config user.name "$username"'
alias gitwork='git config user.email "$work_email" && git config user.name "$username"'

alias gitprivateglobal='git config --global user.email "$private_email" && git config --global user.name "$username"'
alias gitworkglobal='git config --global user.email "$work_email" && git config --global user.name "$username"'
alias cdr='cd $(git root)'
alias cdp='cd ~/projects'

alias ~='cd ~'
alias ..='cd ..'

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

# Tilde commands for Mac

alias tildeswap=$'hidutil property --set \'{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000064,"HIDKeyboardModifierMappingDst":0x700000035}]}\''
alias tilderestore=$'hidutil property --set \'{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000064,"HIDKeyboardModifierMappingDst":0x700000064}]}\''

alias fix-spotlight='fd -t d -I node_modules -x touch "{}/.metadata_never_index"'

alias h='history -r'
