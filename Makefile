prefix=${HOME}
# THIS WILL OVERWRITE ALL THE CONFIG FILES
install:
	
	test -d $(prefix)/.tmux/ || mkdir $(prefix)/.tmux/
	test -d $(prefix/.irssi/ || mkdir $(prefix)/.irssi/
	test -d $(prefix/.oh-my-zsh/ || mkdir $(prefix)/.oh-my-zsh

	cp enc-irssi.theme $(prefix)/.irssi/enc-irssi.theme
	cp settings.zsh $(prefix)/.oh-my-zsh/custom/settings.zsh
	cp enclaved.zsh-theme $(prefix)/.oh-my-zsh/custom/enclaved.zsh-theme
	cp zshrc $(prefix)/.zshrc
	cp tmux.conf $(prefix)/.tmux.conf
	cp tmux.reset.conf $(prefix)/.tmux.reset.conf

	install -m 0744 tmux/tmux-cpu ${prefix}/.tmux/
	install -m 0744 tmux/tmux-mem ${prefix}/.tmux/
	install -m 0744 tmux/tmux-weather ${prefix}/.tmux/
	install -m 0744 tmux/tmux-hosticon ${prefix}/.tmux/
	touch ${prefix}/.tmux/tmp 
