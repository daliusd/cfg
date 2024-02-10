function fish_user_key_bindings
  fish_default_key_bindings -M insert
  fish_vi_key_bindings --no-erase insert

  bind -M insert \ck up-or-search
  bind -M insert \cj down-or-search

  fzf_key_bindings
end
