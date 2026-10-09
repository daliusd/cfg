function ck-disable --description 'Disable project Creator Kit skills and hooks'
    python3 (path dirname (status filename))/../ck-toggle/toggle.py disable $argv
end
