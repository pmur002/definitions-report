
TARFILE = ../definitions-deposit-$(shell date +'%Y-%m-%d').tar.gz
# For building on my office desktop
# Rscript = ~/R/r-devel/BUILD/bin/Rscript
Rscript = /R/bin/Rscript
# Rscript = Rscript

%.xml: %.cml %.bib
	# Protect HTML special chars in R code chunks
	$(Rscript) -e 't <- readLines("$*.cml"); writeLines(gsub("str>", "strong>", gsub("<rcode([^>]*)>", "<rcode\\1><![CDATA[", gsub("</rcode>", "]]></rcode>", t))), "$*-protected.xml")'
	$(Rscript) toc.R $*-protected.xml
	$(Rscript) bib.R $*-toc.xml
	$(Rscript) foot.R $*-bib.xml

%.Rhtml : %.xml
	# Transform to .Rhtml
	xsltproc knitr.xsl $*.xml > $*.Rhtml

%.html : %.Rhtml
	# Use knitr to produce HTML
	$(Rscript) knit.R $*.Rhtml

docker:
	sudo docker build --network "host" -t pmur002/definitions-report .
	sudo docker run --network "host" -v $(shell pwd):/home/work/ -w /home/work --rm pmur002/definitions-report make definitions.html

web:
	make docker
	cp -r ../definitions/* ~/Web/Reports/GraphicsEngine/definitions/

zip:
	make docker
	tar zcvf $(TARFILE) ./*
