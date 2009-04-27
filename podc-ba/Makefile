all: push.ps push.pdf

push.ps: push.dvi
	dvips -t letter -o push.ps push.dvi

push.pdf: push.ps
	ps2pdf push.ps push.pdf

push.dvi: push.tex thesis.bib
	latex push.tex
	bibtex push
	latex push.tex
	bibtex push
	latex push.tex

clean:
	rm -f *~ *.dvi *.log *.aux

distclean:
	rm -f *~ *.dvi *.log *.aux push.ps push.pdf

