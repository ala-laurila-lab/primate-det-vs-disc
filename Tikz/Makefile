all:
	pdflatex Figure1.tex > /dev/null 2>&1
	pdflatex Figure2.tex > /dev/null 2>&1
	pdflatex Figure3.tex > /dev/null 2>&1
	pdflatex FigureS1.tex > /dev/null 2>&1
	pdflatex FigureS2.tex > /dev/null 2>&1
	pdflatex FigureS3.tex > /dev/null 2>&1
	pdflatex FigureS4.tex > /dev/null 2>&1
	pdflatex FigureOutline.tex > /dev/null 2>&1
	gs -dSAFER -dQUIET -dNOPLATFONTS -dNOPAUSE -dBATCH -sOutputFile="Figure1-Preview.png" -sDEVICE=pngalpha -r600 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -dUseTrimBox Figure1.pdf
	gs -dSAFER -dQUIET -dNOPLATFONTS -dNOPAUSE -dBATCH -sOutputFile="Figure2-Preview.png" -sDEVICE=pngalpha -r600 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -dUseTrimBox Figure2.pdf
	gs -dSAFER -dQUIET -dNOPLATFONTS -dNOPAUSE -dBATCH -sOutputFile="Figure3-Preview.png" -sDEVICE=pngalpha -r600 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -dUseTrimBox Figure3.pdf
	gs -dSAFER -dQUIET -dNOPLATFONTS -dNOPAUSE -dBATCH -sOutputFile="FigureS1-Preview.png" -sDEVICE=pngalpha -r600 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -dUseTrimBox FigureS1.pdf
	gs -dSAFER -dQUIET -dNOPLATFONTS -dNOPAUSE -dBATCH -sOutputFile="FigureS2-Preview.png" -sDEVICE=pngalpha -r600 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -dUseTrimBox FigureS2.pdf
	gs -dSAFER -dQUIET -dNOPLATFONTS -dNOPAUSE -dBATCH -sOutputFile="FigureS3-Preview.png" -sDEVICE=pngalpha -r600 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -dUseTrimBox FigureS3.pdf
	gs -dSAFER -dQUIET -dNOPLATFONTS -dNOPAUSE -dBATCH -sOutputFile="FigureS4-Preview.png" -sDEVICE=pngalpha -r600 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -dUseTrimBox FigureS4.pdf

clean:
	find . -name \*.log -type f -delete
	find . -name \*.aux -type f -delete
	find . -name \*.gz -type f -delete







