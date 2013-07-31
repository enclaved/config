ZSH_THEME="enclaved"
COMPLETION_WAITING_DOTS="false"
DISABLE_AUTO_TITLE="true"

# Customize to your needs...
if [[ `uname` == 'Linux' ]];
then
    alias cdd="cd ~/downloads"
    alias cdp='cd ~/projects'

    export PATH=/usr/local/Cellar/ruby/1.9.3-p194/bin:$HOME/bin:/usr/local:/bin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/usr/X11/bin:$HOME/bin/gsd:/usr/local/sbin;
elif [[ `uname` == 'Darwin' ]]
then 
    alias cdd="cd ~/Downloads"
    alias cdp='cd ~/Projects'

    export PATH=/usr/local/go/bin:/usr/local/Cellar/ruby/1.9.3-p194/bin:$HOME/bin:/usr/local:/bin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/usr/X11/bin:/usr/local/sbin:/var/lib/gems/1.8/gems
fi

alias speedtest='wget --output-document=/dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip'
alias speedtest500='wget --output-document=/dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip'
alias serveThis='python -m SimpleHTTPServer'
alias rd='rm -rf'
alias md='mkdir -p'
alias hlast='fc -l 1'
alias hgrep='history | grep'
alias updateplex='curl http://192.168.2.2:32400/library/sections/1/refresh\?force\=1;curl http://192.168.2.2:32400/library/sections/2/refresh\?force\=1'

zstyle ':completion:*' menu select

HISTFILE=~/.history
SAVEHIST=1000000
HISTSIZE=1000000
# Don't overwrite, append!
setopt APPEND_HISTORY
# Write after each command
setopt INC_APPEND_HISTORY
# Killer: share history between multiple shells
setopt SHARE_HISTORY
# If I type cd and then cd again, only save the last one
setopt HIST_IGNORE_DUPS
# Even if there are commands inbetween commands that are the same, still only save the last one
setopt HIST_IGNORE_ALL_DUPS
# Pretty    Obvious.  Right?
setopt HIST_REDUCE_BLANKS
# If a line starts with a space, don't save it.
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE
# When using a hist thing, make a newline show the change before executing it.
setopt HIST_VERIFY
# Save the time and how long a command ran
setopt EXTENDED_HISTORY
setopt HIST_SAVE_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# List directory contents after a 'cd'
function chpwd() {
    emulate -LR zsh
    ls
}

function showfiles() {
    defaults write com.apple.finder AppleShowAllFiles TRUE
    killall Finder && open /System/Library/CoreServices/Finder.app
    osascript 2>/dev/null <<EOF
    tell application "System Events"
        delay 2
		tell application "Finder" to activate desktop
		tell process "Finder"
			keystroke "1" using {command down, option down}
		end tell
	end tell
EOF
}
function hidefiles() {
    defaults write com.apple.finder AppleShowAllFiles FALSE
    killall Finder && open /System/Library/CoreServices/Finder.app
    osascript 2>/dev/null <<EOF
    tell application "System Events"
        delay 2
		tell application "Finder" to activate desktop
		tell process "Finder"
			keystroke "1" using {command down, option down}
		end tell
	end tell
EOF
}
function copyfile {
  [[ "$#" != 1 ]] && return 1
  local file_to_copy=$1
  cat $file_to_copy | pbcopy
}
function copydir {
  pwd | tr -d "\r\n" | pbcopy
}

