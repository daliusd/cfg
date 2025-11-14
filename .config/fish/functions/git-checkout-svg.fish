function git-checkout-svg -d "Checkout modified SVG files identified by GraphicsMagick"
    set -l svg_files (git ls-files -m | xargs gm identify -format "%m:%M\n" 2>/dev/null | rg SVG: | cut -d ":" -f2)
    
    if test (count $svg_files) -eq 0
        echo "No modified SVG files found"
        return 0
    end
    
    echo "Checking out the following SVG files:"
    for file in $svg_files
        echo "  $file"
    end
    
    git checkout $svg_files
end
