if exists('g:GtkGuiLoaded')
  call rpcnotify(1, 'Gui', 'Option', 'Tabline', 0)
  call rpcnotify(1, 'Gui', 'Option', 'Popupmenu', 0)
endif
