
.PHONY: all install

all: install

install: 
	cpanm --installdeps .
