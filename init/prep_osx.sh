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
cecho "###############################################" $red
cecho "#        DO NOT RUN THIS SCRIPT BLINDLY       #" $red
cecho "#         YOU'LL PROBABLY REGRET IT...        #" $red
cecho "#                                             #" $red
cecho "#              READ IT THOROUGHLY             #" $red
cecho "#         AND EDIT TO SUIT YOUR NEEDS         #" $red
cecho "###############################################" $red
echo ""


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

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Set highlight color to green
defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
# Possible values: `WhenScrolling`, `Automatic` and `Always`


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
echo "Change indexing order and disable some search results in Spotlight? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  # Yosemite-specific search results (remove them if your are using OS X 10.9 or older):
  #   MENU_DEFINITION
  #   MENU_CONVERSION
  #   MENU_EXPRESSION
  #   MENU_SPOTLIGHT_SUGGESTIONS (send search queries to Apple)
  #   MENU_WEBSEARCH             (send search queries to Apple)
  #   MENU_OTHER
  defaults write com.apple.spotlight orderedItems -array \
    '{"enabled" = 1;"name" = "APPLICATIONS";}' \
    '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
    '{"enabled" = 1;"name" = "DIRECTORIES";}' \
    '{"enabled" = 1;"name" = "PDF";}' \
    '{"enabled" = 1;"name" = "FONTS";}' \
    '{"enabled" = 0;"name" = "DOCUMENTS";}' \
    '{"enabled" = 0;"name" = "MESSAGES";}' \
    '{"enabled" = 0;"name" = "CONTACT";}' \
    '{"enabled" = 0;"name" = "EVENT_TODO";}' \
    '{"enabled" = 0;"name" = "IMAGES";}' \
    '{"enabled" = 0;"name" = "BOOKMARKS";}' \
    '{"enabled" = 0;"name" = "MUSIC";}' \
    '{"enabled" = 0;"name" = "MOVIES";}' \
    '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
    '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
    '{"enabled" = 0;"name" = "SOURCE";}' \
    '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
    '{"enabled" = 0;"name" = "MENU_OTHER";}' \
    '{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
    '{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
    '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
    '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'
  # Load new settings before rebuilding the index
  killall mds > /dev/null 2>&1
  # Make sure indexing is enabled for the main volume
  sudo mdutil -i on / > /dev/null
  # Rebuild the index from scratch
  sudo mdutil -E / > /dev/null
fi

echo ""
echo "Expanding the save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo ""
echo "Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true


# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo ""
echo "Save to disk, rather than iCloud, by default? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
fi

echo ""
echo "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo ""
echo "Removing duplicates in the 'Open With' menu"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

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


###############################################################################
# General Power and Performance modifications
###############################################################################

echo ""
echo "Disable hibernation? (speeds up entering sleep mode) (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  sudo pmset -a hibernatemode 0
fi

echo ""
echo "Remove the sleep image file to save disk space? (y/n)"
echo "(If you're on a <128GB SSD, this helps but can have adverse affects on performance. You've been warned.)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  sudo rm /Private/var/vm/sleepimage
  echo "Creating a zero-byte file instead"
  sudo touch /Private/var/vm/sleepimage
  echo "and make sure it can't be rewritten"
  sudo chflags uchg /Private/var/vm/sleepimage
fi

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

echo ""
echo "Speeding up wake from sleep to 24 hours from an hour"
# http://www.cultofmac.com/221392/quick-hack-speeds-up-retina-macbooks-wake-from-sleep-os-x-tips/
sudo pmset -a standbydelay 86400

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
echo "Disabling press-and-hold for special keys in favor of key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo ""
echo "Setting a blazingly fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 0

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

# Trackpad: map bottom right corner to right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Disable “natural” (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

###############################################################################
# Screen
###############################################################################

echo ""
echo "Requiring password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo ""
echo "Where do you want screenshots to be stored? (hit ENTER if you want ~/Desktop as default)"
# Thanks https://github.com/omgmog
read screenshot_location
echo ""
if [ -z "${screenshot_location}" ]
then
  # If nothing specified, we default to ~/Desktop
  screenshot_location="${HOME}/Desktop"
else
  # Otherwise we use input
  if [[ "${screenshot_location:0:1}" != "/" ]]
  then
    # If input doesn't start with /, assume it's relative to home
    screenshot_location="${HOME}/${screenshot_location}"
  fi
fi
echo "Setting location to ${screenshot_location}"
defaults write com.apple.screencapture location -string "${screenshot_location}"

echo ""
echo "What format should screenshots be saved as? (hit ENTER for PNG, options: BMP, GIF, JPG, PDF, TIFF) "
read screenshot_format
if [ -z "$1" ]
then
  echo ""
  echo "Setting screenshot format to PNG"
  defaults write com.apple.screencapture type -string "png"
else
  echo ""
  echo "Setting screenshot format to $screenshot_format"
  defaults write com.apple.screencapture type -string "$screenshot_format"
fi

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
fi

echo ""
echo "Show hidden files in Finder by default? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.Finder AppleShowAllFiles -bool true
fi

echo ""
echo "Show dotfiles in Finder by default? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.finder AppleShowAllFiles TRUE
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
echo "Use column view in all Finder windows by default? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.finder FXPreferredViewStyle Clmv
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

echo ""
echo "Increase the size of icons on the desktop and in other icon views? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
fi



###############################################################################
# Finder                                                                      #
###############################################################################

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder: show hidden files by default
#defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder: allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Show item info near icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

# Show item info to the right of the icons on the desktop
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

# Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

# Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Enable AirDrop over Ethernet and on unsupported Macs running Lion
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true


# Show the ~/Library folder
chflags nohidden ~/Library

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true

###############################################################################
# Dock & Mission Control
###############################################################################

echo "Wipe all (default) app icons from the Dock? (y/n)"
echo "(This is only really useful when setting up a new Mac, or if you don't use the Dock to launch apps.)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.dock persistent-apps -array
fi

echo ""
echo "Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate"
defaults write com.apple.dock tilesize -int 36

echo ""
echo "Speeding up Mission Control animations and grouping windows by application"
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true

echo ""
echo "Set Dock to auto-hide and remove the auto-hiding delay? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -float 0
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



###############################################################################
# Mail
###############################################################################

echo ""
echo "Setting email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false


###############################################################################
# Terminal
###############################################################################

echo ""
echo "Enabling UTF-8 ONLY in Terminal.app and setting the Pro theme by default"
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"


###############################################################################
#  iTerm 2
###############################################################################

# Install the Solarized Dark theme for iTerm
open "${HOME}/init/Solarized Dark.itermcolors"

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false


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
# Transmission.app                                                            #
###############################################################################

echo ""
echo "Do you use Transmission for torrenting? (y/n)"
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo ""
  echo "Setting up an incomplete downloads folder in Downloads"
  mkdir -p ~/Downloads/Incomplete
  defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
  defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/Incomplete"

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

## TRACKPAD: MAP BOTTOM RIGHT CORNER TO RIGHT-CLICK
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

## SHOW PERCENTAGE IN BATTERY STATUS
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
defaults write com.apple.menuextra.battery ShowTime -string "NO"

## DISABLE NATURAL SCROLLING
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

## ENABLE TAB IN MODAL DIALOGS
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

## SCROLL WITH CTRL TO ZOOM
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

## DISABLE AUTO-CORRECT
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

## ENABLE HIDPI DISPLAY MODES (REQUIRES RESTART)
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

##FINDER: SHOW HIDDEN FILES BY DEFAULT
#defaults write com.apple.finder AppleShowAllFiles -bool true

##FINDER: SHOW ALL FILENAME EXTENSIONS
#defaults write NSGlobalDomain AppleShowAllExtensions -bool true

##FINDER: SHOW STATUS BAR
#defaults write com.apple.finder ShowStatusBar -bool true

##FINDER: ALLOW TEXT SELECTION IN QUICK LOOK
#defaults write com.apple.finder QLEnableTextSelection -bool true

##DISPLAY FULL POSIX PATH AS FINDER WINDOW TITLE
#defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

##DISABLE THE WARNING WHEN CHANGING A FILE EXTENSION
#defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
##AVOID CREATING .DS_STORE FILES ON NETWORK VOLUMES
#defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

##AUTOMATICALLY OPEN A NEW FINDER WINDOW WHEN A VOLUME IS MOUNTED
# defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
# defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
# defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

##USE LIST VIEW IN ALL FINDER WINDOWS BY DEFAULT
##YOU CAN SET THE OTHER VIEW MODES BY USING ONE OF THESE FOUR-LETTER CODES: ICNV, CLMV, FLWV
defaults write com.apple.finder FXPreferredViewStyle -string “Nlsv”

##DISABLE THE WARNING BEFORE EMPTYING THE TRASH
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# EMPTY TRASH SECURELY BY DEFAULT
# defaults write com.apple.finder EmptyTrashSecurely -bool true
# ENABLE AIRDROP OVER ETHERNET AND ON UNSUPPORTED MACS
# defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# ENABLE HIGHLIGHT HOVER EFFECT FOR THE GRID VIEW OF A STACK (DOCK)
# defaults write com.apple.dock mouse-over-hilte-stack -bool true

# SET THE ICON SIZE OF DOCK ITEMS TO 36 PIXELS
# defaults write com.apple.dock tilesize -int 36

# ENABLE SPRING LOADING FOR ALL DOCK ITEMS
# defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# SHOW INDICATOR LIGHTS FOR OPEN APPLICATIONS IN THE DOCK
# defaults write com.apple.dock show-process-indicators -bool true

# DON’T ANIMATE OPENING APPLICATIONS FROM THE DOCK
# defaults write com.apple.dock launchanim -bool false

# SPEED UP MISSION CONTROL ANIMATIONS
defaults write com.apple.dock expose-animation-duration -float 0.1

# DON’T GROUP WINDOWS BY APPLICATION IN MISSION CONTROL (I.E. USE THE OLD EXPOSÉ BEHAVIOR INSTEAD)
# defaults write com.apple.dock expose-group-by-app -bool false

# DON’T SHOW DASHBOARD AS A SPACE
# defaults write com.apple.dock dashboard-in-overlay -bool true

# REMOVE THE AUTO-HIDING DOCK DELAY
# defaults write com.apple.Dock autohide-delay -float 0

# REMOVE THE ANIMATION WHEN HIDING/SHOWING THE DOCK
defaults write com.apple.dock autohide-time-modifier -float 0

# ENABLE THE 2D DOCK
# defaults write com.apple.dock no-glass -bool true

# AUTOMATICALLY HIDE AND SHOW THE DOCK
# defaults write com.apple.dock autohide -bool true

# MAKE DOCK ICONS OF HIDDEN APPLICATIONS TRANSLUCENT
# defaults write com.apple.dock showhidden -bool true

# RESET LAUNCHPAD
# find ~/Library/Application Support/Dock -name “*.db” -0 1 -delete

# ADD A SPACER TO THE LEFT SIDE OF THE DOCK (WHERE THE APPLICATIONS ARE)
# defaults write com.apple.dock persistent-apps -array-add ‘{tile-data={}; tile-type=“spacer-tile”;}’

# ADD A SPACER TO THE RIGHT SIDE OF THE DOCK (WHERE THE TRASH IS)
# defaults write com.apple.dock persistent-others -array-add ‘{tile-data={}; tile-type=“spacer-tile”;}’

## HOT CORNERS
## TOP LEFT SCREEN CORNER → MISSION CONTROL
#defaults write com.apple.dock wvous-tl-corner -int 2
#defaults write com.apple.dock wvous-tl-modifier -int 0
## TOP RIGHT SCREEN CORNER → DESKTOP
#defaults write com.apple.dock wvous-tr-corner -int 4
#defaults write com.apple.dock wvous-tr-modifier -int 0
## BOTTOM LEFT SCREEN CORNER → START SCREEN SAVER
#defaults write com.apple.dock wvous-bl-corner -int 5
#defaults write com.apple.dock wvous-bl-modifier -int 0

## SHOW ICONS FOR HARD DRIVES, SERVERS, AND REMOVABLE MEDIA ON THE DESKTOP
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

## TURN OFF DISK IMAGE VERIFICATION - POSSIBLE SECURITY PROBLEM - UNCOMMENT IF YOU WANT THIS
#defaults write com.apple.frameworks.diskimages skip-verify -bool true
#defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
#defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
#defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

## SET EXPOSE ANIMATION TO BE FASTEST AND GROUP BY APP
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true

## TURN OF MATCHES ON PREFIX-ONLY IN SAFARI
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

## REMOVE UN-NEEDED LINKS IN SAFARI
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

## TURN ON BACKSPACE KEY TO GO BACK - COMMENTED OUT FOR PEOPLE WHO HATE THIS
#defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

##DISABLE SAFARI’S THUMBNAIL CACHE FOR HISTORY AND TOP SITES
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

## SET TERMINAL TO HOMEBREW THEME, OPTIONS ARE "Pro", "Homebrew", "Man Page", "Novel", "Ocean", "Red Sands", "Silver Aerogel", "Solid Colors"
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Homebrew"
defaults write com.apple.Terminal "Default Window Settings" -string "Homebrew"
defaults write com.apple.Terminal "Startup Window Settings" -string "Homebrew"

## TURN OFF SMART-QUOTES AS IT INTERFERES WITH CODE SNIPPETS
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

## SORT ACTIVITY MONITOR RESULTS BY CPU USAGE
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

## SET SUPER FAST KEY REPEAT, SMALL DELAY
defaults write NSGlobalDomain KeyRepeat -int 0
defaults write NSGlobalDomain InitialKeyRepeat -int 10

## TURN OFF ITUNES DEVICE BACKUP - USE ICLOUD BACKUPS INSTEAD
defaults write com.apple.iTunes AutomaticDeviceBackupsDisabled -bool true

## TURN OFF SIDEBAR ON SAFARI TOPSITES
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

## SET SAFARI HOMEPAGE TO BLANK
defaults write com.apple.Safari HomePage -string "about:blank"

## TURN OFF DASHBOARD
defaults write com.apple.dashboard mcx-disabled -boolean YES

## SET DEFAULT SEARCH TO CURRENT FOLDER
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

## TURN OFF ANIMATIONS
defaults write com.apple.finder DisableAllAnimations -bool true

## SET REASONABLE SCREEN CAPTURE DEFAULTS
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"

## SET FINDER TO DEFAULT TO $HOME
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

## RESTART SYSTEM WHEN FROZEN/HUNG
sudo systemsetup -setrestartfreeze on

## TURN OFF FAST USER SWITCHING
sudo defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool false

## TURN OFF AMBIENT LIGHT SENSOR
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool false

## REST FROM WEB

# Enable Safari’s debug menu
# defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Make Safari’s search banners default to Contains instead of Starts With
# defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Enable the Develop menu and the Web Inspector in Safari
# defaults write com.apple.Safari IncludeDevelopMenu -bool true
# defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
# defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Add a context menu item for showing the Web Inspector in web views
# defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Enable the WebKit Developer Tools in the Mac App Store
# defaults write com.apple.appstore WebKitDeveloperExtras -bool true

# iTunes
# Disable the iTunes store link arrows
# defaults write com.apple.iTunes show-store-link-arrows -bool false
# Disable the Genius sidebar in iTunes
# defaults write com.apple.iTunes disableGeniusSidebar -bool true
# Disable radio stations in iTunes
# defaults write com.apple.iTunes disableRadio -bool true
# Make ⌘ + F focus the search input in iTunes
# defaults write com.apple.iTunes NSUserKeyEquivalents -dict-add “Target Search Field” “@F”

# Mail
# DISABLE SEND AND REPLY ANIMATIONS IN MAIL.APP
defaults write com.apple.mail DisableReplyAnimations -bool true
defaults write com.apple.mail DisableSendAnimations -bool true
# COPY EMAIL ADDRESSES AS FOO@EXAMPLE.COM INSTEAD OF FOO BAR <FOO@EXAMPLE.COM> IN MAIL.APP
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false
# ADD THE KEYBOARD SHORTCUT ⌘ + ENTER TO SEND AN EMAIL IN MAIL.APP
defaults write com.apple.mail NSUserKeyEquivalents -dict-add “Send” “@U21a9”

# Terminal
# Enable “focus follows mouse” for Terminal.app and all X11 apps i.e. hover over a window and start typing in it without clicking first
# defaults write com.apple.terminal FocusFollowsMouse -bool true
# defaults write org.x.X11 wm_ffm -bool true

# Time Machine
# Prevent Time Machine from prompting to use new hard drives as backup volume
# defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Address Book, Dashboard, iCal, TextEdit, and Disk Utility
# Enable the debug menu in Address Book
# defaults write com.apple.addressbook ABShowDebugMenu -bool true

# Enable Dashboard dev mode (allows keeping widgets on the desktop)
# defaults write com.apple.dashboard devmode -bool true

## Remove items from dock that you won't use
##
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Mail/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Contacts/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Calendar/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Reminders/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Maps/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Facetime/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/iTunes/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/iBooks/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock
dloc=$(defaults read com.apple.dock persistent-apps | grep _CFURLString\" | awk '/Notes/ {print NR}') && /usr/libexec/PlistBuddy -c "Delete persistent-apps:$dloc" ~/Library/Preferences/com.apple.dock.plist && killall Dock


## USE PLAIN TEXT MODE FOR NEW TEXTEDIT DOCUMENTS
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF–8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
## Enable the debug menu in Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

## INSTALL HOMEBREW AND COMMANDLINE TOOLS MISSING IN OSX, ALONG WITH SOME PRETTINESS
xcode-select --install
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install wget cmake watch gnu-sed coreutils psutils tmux tmux-mem-cpu-load git

## INSTALL OH MY ZSH AND SET ZSH AS DEFAULT SHELL
sudo curl -L http://install.ohmyz.sh | sh
chsh -s /bin/zsh

## INSTALL CASKROOM AND ALL APPLICATIONS
brew install caskroom/cask/brew-cask

## CODING TOOLS
brew cask install bee iterm2 sourcetree github chefdk

## PICK AN EDITOR
brew cask install sublime-text
defaults write com.apple.LaunchServices LSHandlers -array-add "{LSHandlerContentType=public.plain-text;LSHandlerRoleAll=com.sublimetext.2;}"
## SUBLIME 3 VERSION
#defaults write com.apple.LaunchServices LSHandlers -array-add '{LSHandlerContentType=public.plain-text;LSHandlerRoleAll=com.sublimetext.3;}'

## GET A YOSEMITE ICON FOR SUBLIME
wget -O /Applications/Sublime\ Text\ 2.app/Contents/Resources/Sublime\ Text\ 2.icns https://dribbble.com/shots/1678555-Sublime-Text-3-Replacement-Icon/attachments/265398

## INSTALL SUBLIME PACKAGE MANAGEMENT
wget https://sublime.wbond.net/Package%20Control.sublime-package
mv Package\ Control.sublime-package ~/Library/Application\ Support/Sublime\ Text\ 2/Installed\ Packages/
## SUBLIME 3 VERSION
#mv Package\ Control.sublime-package ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages/
## GET YOUR HIPSTER ON!
git clone https://github.com/phyllisstein/HipsterIpsum.git ~/Library/Application\ Support/Sublime\ Text\ 2/Installed\ Packages/Hipster\ Ipsum


#brew cask install textmate
#defaults write com.apple.LaunchServices LSHandlers -array-add '{LSHandlerContentType=public.plain-text;LSHandlerRoleAll=com.macromates.textmate;}'

#brew cask install atom
#brew cask install textwrangler

## PICK A MOCKUP APP
brew cask install balsamiq
#brew cask install pencil

## SYSTEM UTILITIES
brew cask install disk-inventory-x moom unetbootin istat-menus alfred caffeine keepassx rescuetime the-unarchiver logmein-client royal-tsx jdownloader lastfm

## VIRTUALIZATION / CONTAINERS
brew cask install boot2docker vagrant vmware-fusion virtualbox

## GRAPHICS APPS
## Set "wacom-tablet" to "wacom-bamboo-tablet" for bamboo users
brew cask install google-nik-collection wacom-tablet adobe-creative-cloud

## BROWSERS - UNCOMMENT YOUR FAVOURITE AND/OR INSTALL THEM ALL #################################################
## INSTALL CHROME, REMOTE DESKTOP, CHROMECAST AND TURN OFF ANNOYING SWIPE LEFT RIGHT BEHAVIOUR
brew cask install chromecast chrome-remote-desktop-host google-chrome && defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

## INSTALL FIREFOX
#brew cask install firefox

## INSTALL OPERA
#brew cask install opera
###############################################################################################################

## INSTALL DB TOOLS
brew cask install navicat-for-postgresql toad
## INSTANT MESSAGING
brew cask install adium colloquy slack

## INSTALL BACKUP APPS
brew cask install backblaze carbon-copy-cloner

## BROWSER PLUGINS
brew cask install lastpass-universal silverlight flash-player

## SPOTIFY
brew cask install spotify spotify-menubar spotify-notifications



## INSTALL AWS CLI
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
sudo pip install awscli

## ADD CYBERDOCK TO DOCK
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Cyberduck.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

## ADD SPOTIFY TO DOCK
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Spotify.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

## ADD SPOTIFY TO DOCK
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Sublime Text 2.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

## RUN A MACOS UPDATE
sudo softwareupdate --install -all


# ~/.osx — https://mths.be/osx


###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock tilesize -int 36

# Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Wipe all (default) app icons from the Dock
# This is only really useful when setting up a new Mac, or if you don’t use
# the Dock to launch apps.
#defaults write com.apple.dock persistent-apps -array

# Don’t animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don’t group windows by application in Mission Control
# (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock expose-group-by-app -bool false

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0
# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Disable the Launchpad gesture (pinch with thumb and three fingers)
#defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

# Reset Launchpad, but keep the desktop wallpaper intact
find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -0 1 -delete

# Add a spacer to the left side of the Dock (where the applications are)
#defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
# Add a spacer to the right side of the Dock (where the Trash is)
#defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'

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


# Links to hidden utilities
echo "Creating links to hidden utilities.."
# Archive Utility
sudo ln -s "/System/Library/CoreServices/Applications/Archive Utility.app" "/Applications/Utilities/Archive Utility.app"
# Directory Utility
sudo ln -s "/System/Library/CoreServices/Applications/Directory Utility.app" "/Applications/Utilities/Directory Utility.app"
# Screen Sharing
sudo ln -s "/System/Library/CoreServices/Applications/Screen Sharing.app" "/Applications/Utilities/Screen Sharing.app"
sudo ln -s "/System/Library/CoreServices/Network Diagnostics.app" "/Applications/Utilities/Network Diagnostics.app"
sudo ln -s "/System/Library/CoreServices/Applications/Network Utility.app" "/Applications/Utilities/Network Utility.app"
sudo ln -s "/System/Library/CoreServices/Applications/Wireless Diagnostics.app" "/Applications/Utilities/Wireless Diagnostics.app"
# iOS Simulator
sudo ln -s "/Applications/Xcode.app/Contents/Applications/iPhone Simulator.app" "/Applications/iOS Simulator.app"
echo "Done linking."


## WARN USER
echo ""
cecho "Done!" $cyan
echo ""
echo ""
cecho "################################################################################" $white
echo ""
echo ""
cecho "Note that some of these changes require a logout/restart to take effect." $red
cecho "Killing some open applications in order to take effect." $red
echo ""
sleep 30

###############################################################################
# Kill affected applications                                                  #
###############################################################################

find ~/Library/Application\ Support/Dock -name "*.db" -0 1 -delete

for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dashboard" "Dock" "Finder" "Google Chrome" "Google Chrome Canary" "Mail" \
  "Messages" "Opera" "Safari" "SizeUp" "Spectacle" "SystemUIServer" "Terminal" \
  "Transmission" "Twitter" "iCal", "iTunes"; do
  killall "${app}" > /dev/null 2>&1
done
echo "Done. Note that some of these changes require a logout/restart to take effect."