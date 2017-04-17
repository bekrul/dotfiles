################################################################################
# 2017 - Ben Krulewitch
#
# Readme.txt - Installation Notes regarding my dotfiles repository.  
################################################################################

Get the dotfiles repository
---------------------------
$ cd
$ git clone TODO
This places local repository at ~/dotfiles

Install dotfiles
----------------
To install:
$ dotfiles/Install.sh
This script will error out, telling you which files must be moved/deleted in
order for installation to be successful.  

examine the preexisting dot files, if they still seem useful, move to location
where they will be sourced by dotfiles installed by this repository:
$ mv .bashrc .bashrc_post
$ mv .bash_profile .bash_profile_post
Otherwise move them to a different location or delete them.  

Now run the setup script again.  
$ dotfiles/Install.sh
It should complete without error.  

exit and reenter shell and verify dotfiles are loaded.  

Examine the preexisting dotfiles for anything that should be added to
repository.  


Vim Install/Config
------------------
Vim installation and config is not handled by ~/dotfiles/Install.sh

see os specific notes in:
~/dotfiles/vim/VimInstallWin.txt
~/dotfiles/vim/VimInstallMac.txt
~/dotfiles/vim/VimInstallLinux.txt


Win Env Manual Config
------------------------
to install cygwin, see notes on google drive: Dotfiles Git Setup

setup cygwin terminal keyboard shortcut:
see ~/dotfiles/cygwin/Cygwin64_Terminal.lnk example.  
Shortcut Tab:
    Target: C:\cygwin64\bin\mintty.exe -i /Cygwin-Terminal.ico -
    Shortcut key: Ctrl + Alt + T

Setup virtual desktops:
see ~/dotfiles/win/README.txt

Add ~/dotfiles/cmd to PATH:
Control Panel -> System -> Advanced System Settings -> Environment
Variables... ->  User variables for [user] 
append:
;C:\cygwin64\home\$USER\dotfiles\cmd

to setup CCS6 MSP430 env...
Install CCS6 with MS430 packages
install cygwin package "ctags"
append to path: (adjust with CCS install location)
;C:\TI\ccsv6\utils\bin


Linux Env Manual Config
-----------------------
# BHK TODO - how to setup hotkeys on linux
# workspace hotkeys...
# navigate to workspace:    [ctrl arrow]
# move window to workspace: [ctrl alt arrow]
# open terminal hotkey:     [ctrl alt t]


Mac OS Env Manual Config
------------------------
install xcode

install homebrew, see instructions:
https://brew.sh


install exuberant ctags:
$ brew install ctags
$ which ctags
-if necessary, modify PATH so that ctags at /usr/local/bin/ctags is used
refer to:
http://scholarslab.org/research-and-development/code-spelunking-with-ctags-and-vim/


install eclipse:
requires Java SE Development Kit 8 (JDK 8 Update 121)
http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
ignore link to java package provided by eclipse installer, instead install the above package.

During Eclipse install, select Eclipse IDE for C/C++ Developers. Use default install location.  

iTerm2 - evaluating

kdiff3 - merge?/compare files/directories

SourceTree - gui view of git source trees


IDEs
Arduino
Ccstudio
Eclipse

OS X Hotkeys
------------
<CMD SPACE> - spotlight
<CMD OPT D> - hide/unhide dock
<CTRL Up/Down> - View Desktops (Mission Control)
<CTRL Left/Right> - Switch Desktops 
<click window's title bar & CLRL Left/Right> - Switch window between desktop/space

<CMD SHIFT 3 > - save entire screen to image on desktop 
<CMD SHIFT 4> - save selection to image on desktop
<CMD CTRL SHIFT 3 > - copy entire screen to clipboard
<CMD CTRL SHIFT 4> - copy selection to clipboard
-drag mouse to create selection or use spacebar followed by mouse click to select entire window

Access Apps from spotlight...
Chrome
Word
Excel
terminal
iterm

CCS for mac:
<CMD Left> - go to beginning of line
<CMD Right> - go to end of line
<FN F3> - jump to declaration
<CMD OPT Left/Right> - jump back/forward


? - Enable/Disable FN Keys 
