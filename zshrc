 # Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

if [[ `uname` == 'Linux' ]];
then
	plugins=(git colorize extract websearch themes)

elif [[ `uname` == 'Darwin' ]]
then 
	plugins=(brew git sublime osx colorize extract websearch themes)
fi

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
