if [[ -z $THEME_PREFIX ]]; then
	if [[ `uname` == 'Linux' ]]; 
		then
 		THEME_PREFIX='☁'
 	elif [[ `uname` == 'Darwin' ]];
 		then
	    THEME_PREFIX=''
	fi
fi

#use extended color pallete if available
if [[ $TERM = *256color* || $TERM = *rxvt* ]]; then
    orange="%F{166}"
    purple="%F{135}"
    hotpink="%F{161}"
    limegreen="%F{118}"
else
	orange="$fg[yellow]"
	purple="$fg[magenta]"
	hotpink="$fg[red]"
	limegreen="$fg[green]"
fi

local return_code="%(?..%{$fg[red]%}↵%{$reset_color%})"

PROMPT='%{$fg[green]%}$THEME_PREFIX%{$reset_color%} %{$orange%}%m %{$reset_color%}%{$fg[green]%}%~ %{$reset_color%}%{$(git_prompt_info)%}%{$orange%}%}
%(#.#.») ${return_code}%{$reset_color%} '

RPROMPT='%{$fg[green]%}[%{$reset_color%}%{$orange%}%*%{$reset_color%}%{$fg[green]%}]%{$reset_color%}'


ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$orange%}%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}] %{$fg[red]%}✘%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}] %{$orange%}%}✔%{$reset_color%}"