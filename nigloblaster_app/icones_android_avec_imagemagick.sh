#!/bin/bash

# à améliorer :
#  changer la police
#  passer le texte en paramètres

convert -size 72x72 xc: -draw 'rectangle 0,0,72,72' -fill white -pointsize 24 -draw "text 5,34 'DIEP'" -fill yellow -pointsize 30 -draw "text 5,68 '018'" icon-72.png

convert icon-72.png -resize 48x icon-48.png

convert icon-72.png -resize 36x icon-36.png

# convert -size 72x72 xc: -draw 'rectangle 0,0,72,72' -font FreeSansBold -fill yellow -pointsize 30 -draw "text 5,34 '000'" -fill yellow -pointsize 30 -draw "text 5,68 'AAA'" test72b.png

