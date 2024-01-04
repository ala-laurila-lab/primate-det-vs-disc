#!/bin/bash


echo "Creating Matlab figure panels... "
matlab -nodisplay -r 'setPaths(); updateAllFigurePanels(false); exit;'
echo "Done"

echo "Creating Tikz figure elements... "
(cd Tikz/Icons && make all)
(cd Tikz/Icons && make clean)
(cd Tikz/Models && make all)
(cd Tikz/Models && make clean)
(cd Tikz/Retinal-Processing && make all)
(cd Tikz/Retinal-Processing && make clean)
(cd Tikz/Rod-Bipolar-Pathway && make all)
(cd Tikz/Rod-Bipolar-Pathway && make clean)
echo "Done"

echo "Composing figure panels... "
(cd Tikz && make all)
(cd Tikz && make clean)
echo "Done"

open Tikz/FigureOutline.pdf

