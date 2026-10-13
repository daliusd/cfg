function kosherpi --description 'Launch Pi without Creator Kit skills and extensions'
    node (path dirname (status filename))/../kosherpi/launcher.mjs $argv
end
