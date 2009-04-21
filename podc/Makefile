
push.ps: push.tex
	latex push | sed 's/l\./push.tex:/g' 
	bibtex push
	latex push
	latex push
	dvips push.dvi 
	open push.ps