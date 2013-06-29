install:
	find . -type d | ( cd $(HOME) && xargs mkdir -p )
	find . -type f | egrep -v '~$$' | egrep -v '^\./Makefile$$' | xargs -I %%  ln -sf `pwd`/%% $(HOME)/%%
	date +%s >> $(HOME)/.dotfiles-installed
