#!/bin/bash
################################################################################
# 2017 - Ben Krulewitch 
#
# Install.sh - Installation script for dotfiles dev env.
# 
# Copies files and sets up symbolic links such that dotfiles in this repository
# are used when loading bash prompt.  Vim config is not handled by this script,
# it requires manual setup, see notes in ~/dotfiles/vim.  
#
# This is a nondestructive install script.  It does not overwrite existing files,
# instead erroring out and providing a list of files that must be moved for 
# successful install.  
#
# Note: dotfiles repository must be at ~/dotfiles for the install script to work
################################################################################

# Print message and set flag if passed in file exists.   
function CheckForFile
{
    if [ -f "$1" ]; then
        echo "$1 exists!"
        NoFilesFound=false
    fi    
}


################################################################################
# main
################################################################################

# error on unset variable
set -o nounset

# exit on error
set -o errexit

# return error if any command in a pipeline fails, instead of using
# return code of last command in pipe.  
set -o pipefail

# BHK Note: the platform detection code is duplicated in bashrc.  However, as this 
# script is to be used to install the environment it can't have dependencies on 
# the environment.  

platform='unknown'
unamestr=`uname -s`
if [[ "$unamestr" == 'Linux' ]]; then
    platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
    platform='mac'
elif [ "$(expr substr $unamestr 1 6)" == 'CYGWIN' ]; then
    platform='cygwin'
else
    echo "SetupDotfiles.sh warning: unkown platform $unamestr !"
fi


# Check whether any files already exist at loations we'd like to copy files or
# create symbolic links.  
NoFilesFound=true
CheckForFile ~/.bashrc
CheckForFile ~/.bash_profile
CheckForFile ~/.gitconfig

if [ "$NoFilesFound" != true ]; then
    echo "Aborting with no action.  This script does not overwrite files.  Remove or move files to allow script to execute.  "
    exit 1
fi

###  begin installation (checks complete) ###
# set flag to log each command before executing it, for transparency on
# commands that alter the filesystem.  

# setup symbolic links 
set -x
ln -s ~/dotfiles/bash/bashrc ~/.bashrc
ln -s ~/dotfiles/bash/bash_profile ~/.bash_profile
ln -s ~/dotfiles/git/gitconfig ~/.gitconfig
set +x

#if [[ $platform == 'cygwin' ]]; then
    # No additional cygwin setup required at this time
#fi

#if [[ $platform == 'linux' ]]; then
    # No additional linux setup required at this time
#fi

#if [[ $platform == 'mac' ]]; then
    # No additional mac setup required at this time
#fi

echo "dotfiles installation complete"
