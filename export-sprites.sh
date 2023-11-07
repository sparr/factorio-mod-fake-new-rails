#!/bin/sh

cd graphics/entity

for layer in "metals" "sleepers" "fences" "stone" "signals" "connections"; do
    for entity in "orthogonal" "diagonal" "half-diagonal" "orthogonal-to-half-diagonal" "diagonal-to-half-diagonal"; do
        echo "inkscape export ${layer}-${entity}"
        inkscape fake-new-rails.svg --actions="select-all:layers; object-set-attribute:style, display:none; select-clear; select-by-id:${layer}; object-set-attribute:style, display:inline; export-filename:${layer}-${entity}-1.png; export-id:${entity}; export-do;"
    done

    echo "convert ${layer}-orthogonal"
    convert -rotate  90 ${layer}-orthogonal-1.png ${layer}-orthogonal-2.png

    echo "convert ${layer}-diagonal"
    convert -rotate  90 ${layer}-diagonal-1.png ${layer}-diagonal-2.png

    echo "convert ${layer}-half-diagonal"
    convert -rotate  90 ${layer}-half-diagonal-1.png ${layer}-half-diagonal-2.png
    convert -flop       ${layer}-half-diagonal-1.png ${layer}-half-diagonal-3.png
    convert -rotate  90 ${layer}-half-diagonal-3.png ${layer}-half-diagonal-4.png

    echo "convert ${layer}-orthogonal-to-half-diagonal"
    convert -rotate  90 ${layer}-orthogonal-to-half-diagonal-1.png ${layer}-orthogonal-to-half-diagonal-2.png
    convert -rotate 180 ${layer}-orthogonal-to-half-diagonal-1.png ${layer}-orthogonal-to-half-diagonal-3.png
    convert -rotate 270 ${layer}-orthogonal-to-half-diagonal-1.png ${layer}-orthogonal-to-half-diagonal-4.png
    convert -flop       ${layer}-orthogonal-to-half-diagonal-1.png ${layer}-orthogonal-to-half-diagonal-5.png
    convert -rotate  90 ${layer}-orthogonal-to-half-diagonal-5.png ${layer}-orthogonal-to-half-diagonal-6.png
    convert -rotate 180 ${layer}-orthogonal-to-half-diagonal-5.png ${layer}-orthogonal-to-half-diagonal-7.png
    convert -rotate 270 ${layer}-orthogonal-to-half-diagonal-5.png ${layer}-orthogonal-to-half-diagonal-8.png

    echo "convert ${layer}-diagonal-to-half-diagonal"
    convert -rotate  90 ${layer}-diagonal-to-half-diagonal-1.png ${layer}-diagonal-to-half-diagonal-2.png
    convert -rotate 180 ${layer}-diagonal-to-half-diagonal-1.png ${layer}-diagonal-to-half-diagonal-3.png
    convert -rotate 270 ${layer}-diagonal-to-half-diagonal-1.png ${layer}-diagonal-to-half-diagonal-4.png
    convert -flop       ${layer}-diagonal-to-half-diagonal-1.png ${layer}-diagonal-to-half-diagonal-5.png
    convert -rotate  90 ${layer}-diagonal-to-half-diagonal-5.png ${layer}-diagonal-to-half-diagonal-6.png
    convert -rotate 180 ${layer}-diagonal-to-half-diagonal-5.png ${layer}-diagonal-to-half-diagonal-7.png
    convert -rotate 270 ${layer}-diagonal-to-half-diagonal-5.png ${layer}-diagonal-to-half-diagonal-8.png
done

for dir in "east" "north" "south"; do
    echo "inkscape export ramp-${dir}"
    inkscape fake-new-rails.svg --actions="export-filename:ramp-${dir}.png; export-id:ramp-${dir}; export-do;"
done

echo "convert ramp"
convert -flop ramp-east.png ramp-west.png

echo "inkscape export support"
inkscape fake-new-rails.svg --actions="export-filename:support.png; export-id:support; export-do;"

for f in *.png; do
    pngcrush -ow -new "$f"
done