 # Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

if [[ `uname` == 'Linux' ]];
then
	plugins=(git colorize extract tmux themes)

elif [[ `uname` == 'Darwin' ]]
then 
	plugins=(brew git sublime osx colorize extract tmux themes)
fi

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
