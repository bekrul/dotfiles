#/bin/bash
################################################################################
# 2017 - Ben Krulewitch 
#
# vmakeGenErrFileCCS.sh - Create error file for use with vim's quickfix from 
# output files generated by CCS6 build (gmake Makefile created by CCS ide)
################################################################################

# exit script if it encounters an uninitialized variable
set -o nounset

# exit script if any command returns a nonzero value
set -o errexit

source vmakeCommonSrc

# Note: $ProjDir set by vmakeCommonSrc
#if [ $# -lt 1 ]; then
#    ProjDir=`pwd`
#else
#    ProjDir="$1"
#fi

#echo "Generating vim error file for project in $ProjDir"

# variables controlling script behavior
BuildDir="Debug"

# TI's DriverLib generates numerous diagnostic warnings using TI's compiler, doh!
# Generally, it's better to not include these messages.  
FlgIncDriverLibErrs=false

IncWarn=true
IncDiag=true

FindFlags=
#declare -a FindArgs

if [ "$FlgIncDriverLibErrs" != true ]; then
    # Note: the '*' character is escaped with single quotations so it is not expanded prematurely.  
    FindFlags=-not\ -path\ '*/Debug/driverlib/*'

    #array method of passing asterisks into argument, this works as well
    #but the above is simpler
    #FindArgs[0]="-not -path "
    #FindArgs[1]="*/Debug/driverlib/*"

fi

#echo "FindFlags: $FindFlags"

# Search through debug directory for any files with .err extension
# and compile into a single file in the project root dir.
echo "Creating: $ProjDir/$VMakeErrFile"

find "$ProjDir/Debug" $FindFlags -type f -name "*.err" | xargs cat > "$ProjDir/$VMakeErrFile"

# Annoyingly, the compiler generates error files containing relative paths when the the file
# being referenced is in the build directory - and these paths are relative to the Debug directory.  
# So, change relative links to be relative to the project directory. 
# replace "../ with "
#sed -i 's/"\.\.\//"/g' "$ProjDir/$VMakeErrFile"
# TODO this change required on mac OS, does it work on cygwin?  
sed -i '' 's/"\.\.\//"/g' "$ProjDir/$VMakeErrFile"

# the make command in vim deletes the error file after it has read it.  It seems to work
# best when allowed to do this, so provide a temp file for it to read and delete so that 
# the actual error file is persistent.
echo "Creating: $ProjDir/$VMakeErrFileTmp"
cp "$ProjDir/$VMakeErrFile" "${ProjDir}/${VMakeErrFileTmp}"

#find "$ProjDir/Debug" ${FindArgs[0]} "${FindArgs[1]}" -type f -name "*.err" 
