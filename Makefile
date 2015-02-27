install:
	find . -type d | ( cd $(HOME) && xargs mkdir -p )
	find . -type f | egrep -v '~$$' | egrep -v '^\./Makefile$$' | xargs -I %%  ln -sf `pwd`/%% $(HOME)/%%
	test -d $(HOME)/bin || mkdir $(HOME)/bin
	test -d $(HOME)/src || mkdir $(HOME)/src
	date +%s >> $(HOME)/.dotfiles-installed
