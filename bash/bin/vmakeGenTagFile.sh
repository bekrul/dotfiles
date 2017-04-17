#/bin/bash
################################################################################
# 2017 - Ben Krulewitch 
#
# vmakeGenTagFile.sh - generate a tags file for a project for use with vim.
# used by vmake.  
#
# Search for VS2008 or CCS6 project in the current directory.  If project is found,
# parse the project file for source files to pass to the ctags program which 
# generates the tags.  
# For VS2008 projects, this script requires that the project name matches the 
# name of the project directory.  
#
# Note: requires Exuberant Ctags (5.8)
#  the 'ctags' in the path must be Exuberant Ctags.
################################################################################

# exit script if it encounters an uninitialized variable
set -o nounset

# exit script if any command returns a nonzero value
set -o errexit

#uncomment to echo expanded commands for debugging 
#set -x

source vmakeCommonSrc
   
# It's easier to execute ctags from the project directory.  This way the paths
# passed in to ctags are relative, and so the paths in the tag file are relative as well.  
cd "$ProjDir" 

#echo "Generating vim tags file for project in $ProjDir"
if [ "$IsVSProj" == true ]; then
    echo "Parsing $ProjFileVS for source files to pass to ctags"

    filelist=$(grep RelativePath "$ProjFileVS" | grep -v "\.txt" | sed 's/^[^"]*"\([^"]*\)".*/\1/')
  
    filelist=$(echo "$filelist" | tr '\n' ' ')

	if [[ $ShellPlatform == 'mac' ]]; then
		filelist=$(echo "$filelist" | tr '\' '/')	
	fi

	#echo "filelist=$filelist" 

    echo "Creating: $ProjDir/$CtagsFilename"
    ctags -f "$ProjDir/$CtagsFilename" $CtagFlags $filelist
elif [ "$IsEclipseProj" == true ]; then
    #echo "Parsing $ProjFileEclipse for source files to pass to ctags"

    
	filelist=$(grep locationURI "$ProjFileEclipse" | sed 's/<.*>\(.*\)<\/.*>/\1/')

	if [[ $ShellPlatform == 'mac' ]]; then
	    filelist=$(echo "$filelist" | tr '\r\n' ' ')
	else
   		filelist=$(echo "$filelist" | tr '\n' ' ')
	fi
    filelist=$(echo ${filelist//PARENT-1-PROJECT_LOC/..})
    filelist=$(echo ${filelist//PARENT-2-PROJECT_LOC/..\/..})
    filelist=$(echo ${filelist//PARENT-3-PROJECT_LOC/..\/..\/..})
    filelist=$(echo ${filelist//PARENT-4-PROJECT_LOC/..\/..\/..\/..})
   
	#echo "filelist: $filelist"

    echo "Creating: $ProjDir/$CtagsFilename"


    # via convention, all source files within the project directory are automatically included in the project.
    # as such, they are not listed in the project file and so are not included in $filelist, so we tell ctags to 
    # search the project directory for source files. 
	CtagExcludeFlags=" "
	if [ -d buildinfo ]; then
		CtagExcludeFlags="--exclude buildinfo" 
	fi
    ctags -f "$ProjDir/$CtagsFilename" $CtagFlags $CtagExcludeFlags -R .
    
    # force inclusion of all the files in the common directory...
    #ctags -af "$ProjDir/$CtagsFilename" $CtagFlags -R ../../../src/common

    # skip passing ctags filelist if it is empty
    if [ -n "$filelist" ]; then
        ctags -af "$ProjDir/$CtagsFilename" $CtagFlags $filelist

        # Now that i am including most sources in projects as "linkedResources" directories, the individual source files do not
        # appear in the project file.  Instead, filelist also contains the directories of sources being included.  As such,
        # the following statement adds tags for all linked resources directory.  
        # Note:  It would probably be better to split $filelist into a $filelist and $directorylist, with $filelist tagged above
        #        and $directorylist tagged below, but the following appears to work without additional bash scripting... 
        ctags -af "$ProjDir/$CtagsFilename" $CtagFlags -R $filelist
    fi

	if [ "$IsCCSProj" == true ]; then
		# the following header file is referenced by all projects using the FR20XX family of processors,
		# as it is not listed in the project file it must be explicitly added to the tags.
    	ctags -af "$ProjDir/$CtagsFilename" $CtagFlags "$MspFr2032HeaderFile"
	fi
elif [ "$IsArduinoProj" == true ]; then

	ctags -f "$ProjDir/$CtagsFilename" $CtagFlags --langmap=c++:.ino -R .
	#ctags -f "$ProjDir/$CtagsFilename" $CtagFlags --exclude buildinfo --langmap=c++:.ino -R .

elif [ "$IsMakefileProj" == true ]; then
	echo "skipping tag generation for Makefile based project (no script implemented to pull source files from Makefile)"

else
    echo "Error:  Don't know how to generate tags for this project type"
    cd "$OrigDir"
    exit 1
fi

cd "$OrigDir"

# sample sed script to pull data out of xml tag
#sed 's/<.*>\(.*\)<\/.*>/\1/'

# example of pulling values from within quotes
#sed 's/^[^"]*"\([^"]*\)".*/\1/'  


