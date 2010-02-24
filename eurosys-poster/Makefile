all: eurosys-poster.ps eurosys-poster.pdf

eurosys-poster.ps: eurosys-poster.dvi
	dvips -t letter -o eurosys-poster.ps eurosys-poster.dvi

eurosys-poster.pdf: eurosys-poster.ps
	ps2pdf eurosys-poster.ps eurosys-poster.pdf

eurosys-poster.dvi: eurosys-poster.tex thesis.bib
	latex eurosys-poster.tex
	bibtex eurosys-poster
	latex eurosys-poster.tex
	bibtex eurosys-poster
	latex eurosys-poster.tex

clean:
	rm -f *~ *.dvi *.log *.aux

distclean:
	rm -f *~ *.dvi *.log *.aux eurosys-poster.ps eurosys-poster.pdf

