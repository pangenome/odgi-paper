all: main.pdf

main.pdf: main.tex main.bbl fig/* fig/odgi_tools.pdf *.tex
	pdflatex main.tex </dev/null
	pdflatex main.tex </dev/null

fig/odgi_tools.pdf: fig/odgi_tools.dot
	dot -T pdf fig/odgi_tools.dot > fig/odgi_tools.pdf

main.bbl: document.bib
	pdflatex main </dev/null
	bibtex main </dev/null

clean:
	rm -f main.aux main.toc main.pdf main.log main.bbl main.blg fig/odgi_tools.pdf
