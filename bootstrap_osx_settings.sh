#!/bin/sh

# Alot of these configs have been taken from the various places
# on the web, most from here
# https://github.com/mathiasbynens/dotfiles/blob/master/.osx

# Set the colours you can use
black='\033[0;30m'
white='\033[0;37m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'

# Resets the style
reset=`tput sgr0`

# Color-echo. Improved. [Thanks @joaocunha]
# arg $1 = message
# arg $2 = Color
cecho() {
  echo "${2}${1}${reset}"
  return
}

# Set continue to false by default
CONTINUE=false

echo ""
cecho "Have you read through the script you're about to run and " $red
cecho "understood that it will make changes to your computer? (y/n)" $red
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  CONTINUE=true
fi

if ! $CONTINUE; then
  # Check if we're continuing and output a message if not
  cecho "Please go read the script, it only takes a few minutes" $red
  exit
fi

# Here we go.. ask for the administrator password upfront and run a
# keep-alive to update existing `sudo` time stamp until script has finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX
###############################################################################
echo ""
echo "Would you like to set your computer name (as done via System Preferences >> Sharing)?  (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo "What would you like it to be?"
  read COMPUTER_NAME
  sudo scutil --set ComputerName $COMPUTER_NAME
  sudo scutil --set HostName $COMPUTER_NAME
  sudo scutil --set LocalHostName $COMPUTER_NAME
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $COMPUTER_NAME
fi

echo ""
echo "Hide the Time Machine, Volume, User, and Bluetooth icons?  (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  # Get the system Hardware UUID and use it for the next menubar stuff
  for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
    defaults write "${domain}" dontAutoLoad -array \
      "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
      "/System/Library/CoreServices/Menu Extras/Volume.menu" \
      "/System/Library/CoreServices/Menu Extras/User.menu"
  done

  defaults write com.apple.systemuiserver menuExtras -array \
    "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
    "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
    "/System/Library/CoreServices/Menu Extras/Battery.menu" \
    "/System/Library/CoreServices/Menu Extras/Clock.menu"
fi

echo ""
echo "Hide the Spotlight icon? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search
fi

echo ""
echo "Disable Spotlight indexing for any volume that gets mounted and has not yet been indexed before? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo 'Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.'
  sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
fi

echo ""
echo "Save to disk, rather than iCloud, by default? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
fi

echo ""
echo "Disable smart quotes and smart dashes? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
fi

echo ""
echo "Add ability to toggle between Light and Dark mode in Yosemite using ctrl+opt+cmd+t? (y/n)"
# http://www.reddit.com/r/apple/comments/2jr6s2/1010_i_found_a_way_to_dynamically_switch_between/
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  sudo defaults write /Library/Preferences/.GlobalPreferences.plist _HIEnableThemeSwitchHotKey -bool true
fi

echo ""
echo "Disabling boot time sound effects"
sudo nvram SystemAudioVolume=" "

echo ""
echo "Setting highlight color to green"
defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

echo ""
echo "Always show scrollbars"
# Possible values: `WhenScrolling`, `Automatic` and `Always`
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

echo ""
echo "Expanding the save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo ""
echo "Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo ""
echo "Disable the “Are you sure you want to open this application?” dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo ""
echo "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo ""
echo "Removing duplicates in the 'Open With' menu"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

echo ""
echo "Show percentage in battery status"
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
defaults write com.apple.menuextra.battery ShowTime -string "NO"

echo ""
echo "Turn off fast user switching"
sudo defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool false
###############################################################################
# General Power and Performance modifications
###############################################################################
echo ""
echo "Disable the sudden motion sensor? (it's not useful for SSDs/current MacBooks) (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  sudo pmset -a sms 0
fi

echo ""
echo "Disable system-wide resume? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false
fi

echo ""
echo "Disable the menubar transparency? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.universalaccess reduceTransparency -bool true
fi
################################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input
###############################################################################
echo ""
echo "Increasing sound quality for Bluetooth headphones/headsets"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

echo ""
echo "Enabling full keyboard access for all controls (enable Tab in modal dialogs, menu windows, etc.)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo ""
echo "Disable auto-correct? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
fi

echo ""
echo "Setting trackpad & mouse speed to a reasonable number"
defaults write -g com.apple.trackpad.scaling 2
defaults write -g com.apple.mouse.scaling 2.5

echo ""
echo "Turn off keyboard illumination when computer is not used for 5 minutes"
defaults write com.apple.BezelServices kDimTime -int 300

echo ""
echo "Disable display from automatically adjusting brightness? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool false
fi

echo ""
echo "Disable keyboard from automatically adjusting backlight brightness in low light? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Keyboard Enabled" -bool false
fi

echo ""
echo "Trackpad: map bottom right corner to right-click? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
fi

echo ""
echo "Disable “natural” (Lion-style) scrolling? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
fi

###############################################################################
# Screen
###############################################################################
echo ""
echo "Requiring password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo ""
echo "Enabling subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2

echo ""
echo "Enabling HiDPI display modes (requires restart)"
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true
###############################################################################
# Finder
###############################################################################
echo ""
echo "Show icons for hard drives, servers, and removable media on the desktop? (y/n)"
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
fi

echo ""
echo "Show hidden files in Finder by default? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.Finder AppleShowAllFiles -bool true
fi

echo ""
echo "Show all filename extensions in Finder by default? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
fi

echo ""
echo "Show status bar in Finder by default? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.finder ShowStatusBar -bool true
fi

echo ""
echo "Display full POSIX path as Finder window title? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
fi

echo ""
echo "Disable the warning when changing a file extension? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
fi

echo ""
echo "Use list view in all Finder windows by default? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  ##YOU CAN SET THE OTHER VIEW MODES BY USING ONE OF THESE FOUR-LETTER CODES: ICNV, CLMV, FLWV
  defaults write com.apple.finder FXPreferredViewStyle Nlsv
fi

echo ""
echo "Avoid creation of .DS_Store files on network volumes? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
fi

echo ""
echo "Disable disk image verification? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.frameworks.diskimages skip-verify -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true
fi

echo ""
echo "Allowing text selection in Quick Look/Preview in Finder by default"
defaults write com.apple.finder QLEnableTextSelection -bool true

echo ""
echo "Show item info near icons on the desktop and in other icon views? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
fi

echo ""
echo "Show item info to the right of the icons on the desktop? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist
fi

echo ""
echo "Enable snap-to-grid for icons on the desktop and in other icon views? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
fi

echo ""
echo "Increase grid spacing for icons on the desktop and in other icon views? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
fi

# Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

echo ""
echo "Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons"
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: disable window animations and Get Info animations
# defaults write com.apple.finder DisableAllAnimations -bool true

echo ""
echo "SET FINDER TO DEFAULT TO $HOME"
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

echo ""
echo "Finder: show path bar"
defaults write com.apple.finder ShowPathbar -bool true

echo ""
echo "When performing a search, search the current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo ""
echo "Enable spring loading for directories"
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
#defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Disable the warning before emptying the Trash
#defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Empty Trash securely by default
#defaults write com.apple.finder EmptyTrashSecurely -bool true

echo ""
echo "Showing the ~/Library folder"
chflags nohidden ~/Library

echo ""
echo "Expanding the following File Info panes: General, Open with, and Sharing & Permissions"
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true
###############################################################################
# Dock & Mission Control Dock, Dashboard, and hot corners
###############################################################################
echo ""
echo "Setting the icon size of Dock items to 16 pixels"
defaults write com.apple.dock tilesize -int 16

echo ""
echo "Speeding up Mission Control animations and disable grouping windows by application"
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool false

echo ""
echo "Set Dock to auto-hide and remove the auto-hiding delay? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -float 0
fi

echo ""
echo "Disable dashboard? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.dashboard mcx-disabled -bool true
  # Don’t show Dashboard as a Space
  defaults write com.apple.dock dashboard-in-overlay -bool true
fi

echo ""
echo "Enable highlight hover effect for the grid view of a stack (Dock)"
defaults write com.apple.dock mouse-over-hilite-stack -bool true

echo ""
echo "Change minimize/maximize window effect to scale"
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application’s icon
# defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items
#defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

echo ""
echo "Show indicator lights for open applications in the Dock"
defaults write com.apple.dock show-process-indicators -bool true

# Don’t animate opening applications from the Dock
# defaults write com.apple.dock launchanim -bool false

echo ""
echo "Don’t automatically rearrange Spaces based on most recent use"
defaults write com.apple.dock mru-spaces -bool false

echo ""
echo "Make Dock icons of hidden applications translucent"
defaults write com.apple.dock showhidden -bool true

echo ""
echo "Setting Hot Corners"
# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# Top left screen corner → Mission Control
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0
# Top right screen corner → Desktop
defaults write com.apple.dock wvous-tr-corner -int 4
defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom left screen corner → Start screen saver
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

echo ""
echo "Remove items from dock that you won't use"
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Mail/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Contacts/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Calendar/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Reminders/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Maps/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Facetime/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/iTunes/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/iBooks/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Notes/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock

###############################################################################
# Time Machine
###############################################################################
echo ""
echo "Prevent Time Machine from prompting to use new hard drives as backup volume? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
fi

echo ""
echo "Disable local Time Machine backups? (This can take up a ton of SSD space on <128GB SSDs) (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  hash tmutil &> /dev/null && sudo tmutil disablelocal
fi
###############################################################################
# Chrome, Safari, & WebKit
###############################################################################
echo ""
echo "Enabling the Develop menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

echo ""
echo "Adding a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

echo ""
echo "Using the system-native print preview dialog in Chrome"
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

echo ""
echo "Allow installing user scripts via GitHub Gist or Userscripts.org"
defaults write com.google.Chrome ExtensionInstallSources -array "https://gist.githubusercontent.com/" "http://userscripts.org/*"
defaults write com.google.Chrome.canary ExtensionInstallSources -array "https://gist.githubusercontent.com/" "http://userscripts.org/*"
## TURN OFF SIDEBAR ON SAFARI TOPSITES
# defaults write com.apple.Safari ShowSidebarInTopSites -bool false

## SET SAFARI HOMEPAGE TO BLANK
# defaults write com.apple.Safari HomePage -string "about:blank"
###############################################################################
# Terminal
###############################################################################
echo ""
echo "Enabling UTF-8 ONLY in Terminal.app and setting the Pro theme by default"
## SET TERMINAL TO HOMEBREW THEME, OPTIONS ARE "Pro", "Homebrew", "Man Page", "Novel", "Ocean", "Red Sands", "Silver Aerogel", "Solid Colors"
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"
###############################################################################
#  iTerm 2
###############################################################################
# Install the Solarized Dark theme for iTerm
# open "${HOME}/init/Solarized Dark.itermcolors"
echo ""
echo "Don’t display the annoying prompt when quitting iTerm"
defaults write com.googlecode.iterm2 PromptOnQuit -bool false
###############################################################################
# Transmission.app                                                            #
###############################################################################
echo ""
echo "Do you use Transmission for torrenting? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  # echo ""
  # echo "Setting up an incomplete downloads folder in Downloads"
  # mkdir -p ~/Downloads/Incomplete
  # defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
  # defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/Incomplete"

  echo ""
  echo "Don't prompt for confirmation before downloading"
  defaults write org.m0k.transmission DownloadAsk -bool false

  echo ""
  echo "Trash original torrent files"
  defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

  echo ""
  echo "Hide the donate message"
  defaults write org.m0k.transmission WarningDonate -bool false

  echo ""
  echo "Hide the legal disclaimer"
  defaults write org.m0k.transmission WarningLegal -bool false
fi

###############################################################################
# Sublime Text
###############################################################################
echo ""
echo "Do you use Sublime Text 3 as your editor of choice, and is it installed?"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  # Installing from homebrew cask does the following for you!
  # echo ""
  # echo "Linking Sublime Text for command line usage as subl"
  # ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl

  echo ""
  echo "Setting Git to use Sublime Text as default editor"
  git config --global core.editor "subl -n -w"
fi
###############################################################################
# Misc
###############################################################################
echo ""
echo "TURN OFF ITUNES DEVICE BACKUP - USE ICLOUD BACKUPS INSTEAD?"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.iTunes AutomaticDeviceBackupsDisabled -bool true
fi

echo ""
echo "USE PLAIN TEXT MODE FOR NEW TEXTEDIT DOCUMENTS"
defaults write com.apple.TextEdit RichText -int 0

echo ""
echo "Open and save files as UTF–8 in TextEdit"
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

echo ""
echo "SORT ACTIVITY MONITOR RESULTS BY CPU USAGE"
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

echo ""
echo "SET REASONABLE SCREEN CAPTURE DEFAULTS"
#defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"

echo ""
echo "RESTART SYSTEM WHEN FROZEN/HUNG"
sudo systemsetup -setrestartfreeze on

## RUN A MACOS UPDATE
sudo softwareupdate --install -all

echo "Creating links to hidden utilities.."
sudo ln -s "/System/Library/CoreServices/Applications/Archive Utility.app" "/Applications/Utilities/Archive Utility.app"
sudo ln -s "/System/Library/CoreServices/Applications/Directory Utility.app" "/Applications/Utilities/Directory Utility.app"
sudo ln -s "/System/Library/CoreServices/Applications/Screen Sharing.app" "/Applications/Utilities/Screen Sharing.app"
sudo ln -s "/System/Library/CoreServices/Network Diagnostics.app" "/Applications/Utilities/Network Diagnostics.app"
sudo ln -s "/System/Library/CoreServices/Applications/Network Utility.app" "/Applications/Utilities/Network Utility.app"
sudo ln -s "/System/Library/CoreServices/Applications/Wireless Diagnostics.app" "/Applications/Utilities/Wireless Diagnostics.app"
sudo ln -s "/Applications/Xcode.app/Contents/Applications/iPhone Simulator.app" "/Applications/iOS Simulator.app"
echo "Done linking."

# Reset Launchpad, but keep the desktop wallpaper intact
find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -0 1 -delete

echo "Done. Now logout/restart to process changes."