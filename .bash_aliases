alias e=nvim-gtk
alias cfg='git --git-dir=/home/dalius/.cfg/ --work-tree=/home/dalius'

username='Dalius Dobravolskas'
private_email='dalius.dobravolskas@gmail.com'
work_email='dalius.dobravolskas@balto.eu'

alias gitprivate='git config user.email "$private_email" && git config user.name "$username"'
alias gitwork='git config user.email "$work_email" && git config user.name "$username"'

alias gitprivateglobal='git config --global user.email "$private_email" && git config --global user.name "$username"'
alias gitworkglobal='git config --global user.email "$work_email" && git config --global user.name "$username"'

alias ~='cd ~'
alias ..='cd ..'
