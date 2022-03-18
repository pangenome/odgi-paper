all: manuscript.pdf

main.pdf: main.tex main.bbl fig/* fig/odgi_tools.pdf *.tex
	pdflatex main.tex </dev/null
	pdflatex main.tex </dev/null

fig/odgi_tools.pdf: fig/odgi_tools.dot
	dot -T pdf fig/odgi_tools.dot > fig/odgi_tools.pdf

main.bbl: document.bib
	pdflatex main </dev/null
	bibtex main </dev/null

manuscript.pdf: main.pdf
	pdftk main.pdf cat 1-9 output manuscript.pdf
	pdftk main.pdf cat 10-17 output supplement.pdf

clean:
	rm -f main.aux main.toc main.pdf main.log main.bbl main.blg fig/odgi_tools.pdf manuscript.pdf supplement.pdf
