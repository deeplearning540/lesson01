DTAPP ?= $(HOME)/node_modules/.bin/decktape

OUTPUTPDF?=$(shell basename $(PWD))-$(USER).pdf

all: index.html

reveal-latest.tar.gz :
	#wget -O $@ $(shell curl -s https://api.github.com/repos/hakimel/reveal.js/releases/latest|jq -r '.tarball_url')
	@wget -O $@ https://github.com/hakimel/reveal.js/archive/3.9.2.tar.gz


#based on https://github.com/jgm/pandoc/wiki/Using-pandoc-to-produce-reveal.js-slides
reveal.js : reveal-latest.tar.gz
	@tar -xzvf $<
	@ln -s -f reveal.js-3* $@

reveal_patched : reveal.js
	@sed -i -e '/node-sass/s/4.13/4.14/g' reveal.js/package.json

reveal.js/css/theme/hzdr.css : extras/reveal.js/css/theme/hzdr.css reveal_patched
	@ln -s -f $(PWD)/extras/reveal.js/css/theme/hzdr.css reveal.js/css/theme/hzdr.css

reveal.js/css/theme/dejavu-sans : reveal_patched
	@cp -rv custom/themes/fonts reveal.js/css/theme

reveal.js/css/theme/images/%.png : custom/themes/images/%.png reveal_patched
	@mkdir -p reveal.js/css/theme/images/
	@cp -rv $< $@


reveal.js/node_modules : reveal_patched
	@cd reveal.js && npm install && npm run build -- css-themes

soft_prepare : reveal_patched reveal.js/node_modules
	@npm install decktape

reveal.js/css/theme/source/%.scss : custom/themes/%.scss
	@cp -rv $< $@

reveal.js/css/theme/fonts/%: custom/%
	@mkdir -p $@
	@cp -rv $</css $</webfonts $@

theme_prepare : reveal.js/css/theme/images/helmholtz_ai_thin.png \
				reveal.js/css/theme/images/helmholtz_ai_dark_footer.png \
				reveal.js/css/theme/source/helmholtzai-dark.scss \
				reveal.js/css/theme/source/helmholtzai-white.scss \
				reveal.js/css/theme/fonts/fontawesome \
				reveal.js/css/theme/fonts/dejavu-sans \
				reveal.js/css/theme/fonts/hermann

css-themes: theme_prepare
	@cd reveal.js && npm run build -- css-themes

prepare : soft_prepare css-themes

%.html : %.md css-themes
	@pandoc -t revealjs -s -o $@ $< \
			-V revealjs-url=./reveal.js \
			-V theme=helmholtzai-dark #\


pandoc_theme.html :
	@pandoc -D revealjs > pandoc_theme.html

#TODO: try to obtain the name of the repo
#      and use it for the pdf name
$(OUTPUTPDF): index.pdf
	@cp -v $< $@

pdf: $(OUTPUTPDF)

%.pdf : %.html
	$(DTAPP) reveal $<\?fragments=true $@

print_images: index.md
	@grep '\!\[' index.md|sed -e 's@.*(\(.*\)).*@\1@'|sed -e 's/{\(.*\)}/\1/'
	@grep 'data-background-image' index.md|sed -e 's@.*image="\(.*\)" .*@\1@'

add_images:
	@git add -f -v `grep '\!\[' index.md|sed -e 's@.*(\(.*\)).*@\1@'|sed -e 's/{\(.*\)}/\1/'`
	@git add -f -v `grep 'data-background-image' index.md|sed -e 's@.*image="\(.*\)" .*@\1@'`

clean:
	@rm -fvr reveal.js/css/theme/fonts/*
	@rm -fv reveal.js/css/theme/images/helmholtz*png
	@rm -fv reveal.js/css/theme/helmholtz*.css
	@rm -fv index.html index.pdf

distclean: clean
	@rm -rf reveal*tar.gz
	@rm -rf reveal.js/node_modules
	@rm -rf reveal.js reveal.js-3*
