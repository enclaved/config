###############################################################################
# Install software
###############################################################################
## INSTALL HOMEBREW AND COMMANDLINE TOOLS MISSING IN OSX, ALONG WITH SOME PRETTINESS
xcode-select --install
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install wget gnu-sed psutils tmux git

## INSTALL OH MY ZSH AND SET ZSH AS DEFAULT SHELL
sudo curl -L http://install.ohmyz.sh | sh
chsh -s /bin/zsh

## INSTALL CASKROOM AND ALL APPLICATIONS
brew install caskroom/cask/brew-cask

## CODING TOOLS
brew cask install iterm2 mamp

## PICK AN EDITOR
brew cask install sublime-text
## SUBLIME 3 VERSION
defaults write com.apple.LaunchServices LSHandlers -array-add '{LSHandlerContentType=public.plain-text;LSHandlerRoleAll=com.sublimetext.3;}'

## GET A YOSEMITE ICON FOR SUBLIME
wget -O /Applications/Sublime\ Text\ 3.app/Contents/Resources/Sublime\ Text\ 3.icns https://dribbble.com/shots/1678555-Sublime-Text-3-Replacement-Icon/attachments/265398

## INSTALL SUBLIME PACKAGE MANAGEMENT
wget https://sublime.wbond.net/Package%20Control.sublime-package
mv Package\ Control.sublime-package ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages/
## GET YOUR HIPSTER ON!
git clone https://github.com/phyllisstein/HipsterIpsum.git ~/Library/Application\ Support/Sublime\ Text\ 2/Installed\ Packages/Hipster\ Ipsum

## SYSTEM UTILITIES
brew cask install omnidisksweeper moom istat-menus alfred caffeine royal-tsx appcleaner bartender clipmenu dropbox

## 3D Printer Utilities
brew cask install sketchup slic3r blender

## Misc stuff
brew cask install transmission-remote-gui tunnelblick unrarx transmit transmission keka

## VIRTUALIZATION / CONTAINERS
brew cask install vmware-fusion virtualbox

## GRAPHICS APPS
## Set "wacom-tablet" to "wacom-bamboo-tablet" for bamboo users
#  brew cask install google-nik-collection wacom-tablet adobe-creative-cloud

## BROWSERS - UNCOMMENT YOUR FAVOURITE AND/OR INSTALL THEM ALL #################################################
## INSTALL CHROME, REMOTE DESKTOP, CHROMECAST AND TURN OFF ANNOYING SWIPE LEFT RIGHT BEHAVIOUR
brew cask install chromecast chrome-remote-desktop-host google-chrome
# defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

## BROWSER PLUGINS
brew cask install lastpass-universal silverlight flash-player

## Add applications to dock
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Transmit.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

# todo
# setup desktop specific apps
# additional webdev stuff nodejs, compass, scss etc
# brew cask install firefox github pencil