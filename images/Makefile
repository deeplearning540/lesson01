TEXFILES=$(wildcard *tex)
SVGFILES=$(TEXFILES:.tex=.svg)
PNGFILES=$(TEXFILES:.tex=.png)

all: ${PNGFILES}

#TODO: using the svg export with the tikz option for standalone doesn't work right
#      need to install texlive-dvisvgm in order to try: latex <filestem> && dvisvgm <filestem>

%.dvi : %.tex
	@xelatex $<

# %.svg : %.dvi
# 	@dvisvgm $<

%.pdf : %.tex
	@xelatex $<

%.png : %.svg
	@inkscape --export-type=png -o $@ $<

%.png : %.pdf
	@convert -verbose -density 150 -quality 100 -flatten -trim $< $@

%.jpg : %.pdf
	@convert -verbose -density 150 -quality 100 -flatten -trim $< $@

clean:
	@rm -fv *eps *svg *aux *dvi *log ./*~
