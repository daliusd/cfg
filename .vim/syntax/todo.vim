" Vim syntax file
" Language: TODO
" Maintainer:       Dalius Dobravolskas
"
"
" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match   todoNotStarted  "^\ *-.*$"
syn match   todoFinished    "^\ *+.*$"
syn match   todoQuestion    "^\ *?.*$"
syn match   todoTitle       "^[^-+?\ ].*$"

if version >= 508 || !exists("did_todo_syn_inits")
  if version <= 508
    let did_todo_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default methods for highlighting.  Can be overridden later

  hi TodoFinishedSyntax         ctermfg=Green   guifg=#40AA40 gui=bold
  hi TodoNotStartedSyntax       ctermfg=Red     guifg=#AA4040
  hi TodoQuestionSyntax         ctermfg=Cyan    guifg=#4040AA
  hi TodoTitleSyntax            gui=bold

  HiLink todoNotStarted         TodoNotStartedSyntax
  HiLink todoFinished           TodoFinishedSyntax
  HiLink todoQuestion           TodoQuestionSyntax
  HiLink todoTitle              TodoTitleSyntax

  delcommand HiLink
endif

let b:current_syntax = "todo"
