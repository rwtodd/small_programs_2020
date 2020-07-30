.POSIX:
.SUFFIXES:
.SUFFIXES: .ms .pdf .ps

all: ly.ps
#	evince ly.ps

pdf: ly.pdf

check:
	@lua ly.lua 0 2020 0 3020
	@lua ly.lua 1 2020 0 2021
	@lua ly.lua 0 2020 365 2020

.ms.ps:
	eqn -Tps < $< | groff -Tps -ms > $@ 
.ps.pdf:
	ps2pdf -dPDFSETTINGS=/prepress $< $@ 
