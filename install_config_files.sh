#!/bin/bash

if [[ $OSTYPE =~ darwin* ]]; then
 # Mac OSX

  # Install Sublime Text settings
  cp -r init/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text*/Packages/User/Preferences.sublime-settings 2> /dev/null
  cp -r init/Solarized\ \(dark\).sublime-theme ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Default.sublime-theme 2> /dev/null
  cp -r init/Solarized\ \(dark\).tmTheme ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Solarized\ \(dark\).tmTheme 2> /dev/null

  # Install the Solarized Dark theme for iTerm
  open init/Solarized\ Dark.itermcolors

# elif [[ $OSTYPE =~ linux* ]]; then
fi

# Install vim settings and Solarized theme
cp -R .vim ~/
cp -R .vimrc ~/

# Install tmux theme and scripts, Tmux theme not optimized for Solarized
cp -R .tmux ~/
cp -r .tmux.conf ~/.tmux.conf
cp -r .tmux.reset.conf ~/.tmux.reset.conf
touch ~/.tmux/tmp

cp -r init/settings.zsh ~/.oh-my-zsh/custom/settings.zsh
cp -r init/enclaved.zsh-theme ~/.oh-my-zsh/custom/enclaved.zsh-theme
cp -r .zshrc ~/.zshrc