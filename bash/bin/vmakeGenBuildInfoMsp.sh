#/bin/bash
################################################################################
# 2017 - Ben Krulewitch 
#
# vmakeGenBuildInfoMsp.sh - save info on firmware built by vmake.  
# run from directory containing CCS project.  Paths below are relative to
# project directory.  
#
# Appends line to:
# buildinfo/BuildInfo.log
# see logBuildInfo() and logBuildInfoHdr() below for fields included
#
# Creates build info directory with unique folder name:
# buildinfo/<changeset>_<label>_<[A-Z]>
# label is set by command line parameter or the contents of:
# buildinfo/.default_label
# <changeset> is the contents of file:
# buildinfo/.changeset
# update the contents of this folder by executing script with options -s or --changeset
# This gets the changeset of every file in Msp430 base dir from TFS and saves 
# the latest value to buildinfo/.changeset.  
#
# files copied to labelled dir:
# Debug/<ProjName>.map
# Debug/makefile
# Debug/<ProjName>_linkinfo.xml
# .project
# .cproject
# .ccsproject
# files created in labelled dir:
# BuildCmd.txt 			- the command used to build the firmware -cl430 plus arguments. 
# BuildSymbols.txt		- all symbols firmware was built with, one per line
# BuildInfoLogLine.txt 	- contains the line appended to buildinfo/BuildInfo.log
# VerboseInfo.txt		- includes info in BuildInfoLogLine and additional info
# SelectInfo.txt		- customize for most common desired info
#
# usage:
# invoke via vmake:
# $vmake -l
# generate build info using default label
#
# $vmake -L|--label <LABEL>
# generate build info with provided label
#
# vmake behavior
#  buildinfo only generated if build succeeds 
#  - generate info on failed builds by executing this script directly
#
# when run directly:
# see usage() function below


################################################################################

usage () 
{
    cmdName=$(basename "$0")
    echo "Usage: $cmdName [options]"
    echo "Options:"
	echo "-s, --changeset                           Get identifier for local changeset, save to buildinfo/.changeset and exit."
    #echo "-C DIRECTORY, --directory DIRECTORY		Change to DIRECTORY before doing anything.  [not implemented]"
	echo "-h, --help                         		Print this message and exit."
	echo "-L LABEL,--label LABEL                    Use LABEL in unique folder name.  If not provided, default label is used."
	echo "-sl, --savelabel LABEL					save LABEL to buildinfo/.default_label."
	echo "-o,--sdout								write brief info on build to stdout."	
	echo "--hdr                                     Append field header line to log file."
}

parseArgs()
{
	# set default argument values
    MakeRules=all
    ProjPath=.
	BuildLabel=

    DoAppendHdr=false
	DoChangesetOpt=false
	DoSaveLabel=false
	DoStdOutShort=false

    #echo "parseArgs..."
    #echo "NumArgs: $#"
    #echo "Args: $@"

    # parse all arguments with format '-flag value', ie '-x xxxxx', or '-xx x'
    UnhandledArgs=()
    while [[ $# > 1 ]]
    do
        key="$1"
        case $key in
			# Note: this argument doesn't work, because vmakeCommonSrc relies on
			#  being executed from project directory in order to extract project name
			#  from the current directory name.  
            #    -C|--directory)
            #    ProjPath="$2"
            #    shift # past argument
            #;;
                -sl|--savelabel)
                BuildLabel="$2"
				DoSaveLabel=true
                shift # past argument
            ;;
                -L|--label)
                BuildLabel="$2"
                shift # past argument
            ;;
            	*)
                # unknown option, add to MakeRules
                UnhandledArgs+=($key) 
                # no shift, as next argument could be a key 
                #shift # past argument
            ;;
        esac
        shift # past argument or value
    done

    # combine arguments not yet handled into a singla array for further processing 
    if [[ -z "${UnhandledArgs+x}" ]]; then
        RemainingArgs="$@"
    else
        RemainingArgs=("${UnhandledArgs[@]}" "$@") 
    fi

    #echo "parsed all '-flag value' arguments"
    #echo "RemainingArgs: ${RemainingArgs[*]}"

    # now parse all arguments with format '-flag', ie -xxx
    UnhandledArgs=
    for key in "${RemainingArgs[@]}"
    do
        case $key in
        -s|--changeset)
			DoChangesetOpt=true
        ;;
        -h|--help)
            # print usage info and exit
            usage
            exit 0
        ;;
		-o|--stdout)
			DoStdOutShort=true
		;;
        --hdr)
		    DoAppendHdr=true
		;;
        *)
            # unknown option, add to UnhandledArgs 
            UnhandledArgs="$UnhandledArgs $key" 
        ;;
        esac
    done
   
	#echo "parsed all '-flag' arguments"
    #echo "UnhandledArgs: $UnhandledArgs"
    
    # If UnhandledArgs contains only spaces, clear it
    if [[ -z "${UnhandledArgs// }" ]]; then
        UnhandledArgs=
    fi

    if ! [[ -z "$UnhandledArgs" ]]; then
        echo "ignoring unknown arguments: $UnhandledArgs"
    fi

    #echo "ProjPath = $ProjPath"
}


logBuildInfo()
{
	printf "%s\t%s\t%s\t%s\t%s\t%s\n" ${UniqFolderName} ${Changeset} ${TotalSize} ${DateNow} ${BuildOptLvl} ${BuildOptForSpeedLvl}
}

logBuildInfoHdr()
{
    printf "Folder\tChangeset\tSize\tDate\tOptLvl\tOptForSpeed\n"
}

logVerboseInfo()
{
	# Note: these numbers do not fully line up with output provided by CCS console and
	#  memory allocation view.  The TI tools appear to be inconsistent with what it considers
	#  part of the data section.  

	printf 'MainFramSize...\n'
	printf 'fr2032\tfr2033\n'
	printf '%u\t%u\n' 8192 15360
	printf '0x%x\t0x%x\n' 8192 15360

	printf 'ProgramSize...\n'	
	printf 'text\tbrintvec\tproxyintr\tsigsintvec\n'
    printf '%u\t%d\t%d\t%d\n' $textSize $brintVecSize $proxyIntrSize $reservedSigAndVecSize 
    printf '0x%x\t0x%x\t0x%x\t0x%x\n' $textSize $brintVecSize $proxyIntrSize $reservedSigAndVecSize 

	printf 'DataSize...\n'
	printf 'const\tinitarr\tcinit\tpersist\tcrctab\n'
	printf '%d\t%d\t%d\t%d\t%d\n' $constSize $initarraySize $cinitSize $persistSize $crctabSize 
	printf '0x%x\t0x%x\t0x%x\t0x%x\t0x%x\n' $constSize $initarraySize $cinitSize $persistSize $crctabSize 

	printf "Total\tProgram\tData\n" 
	printf '%d\t%d\t%d\n' $TotalSize $ProgramSize $DataSize
	printf '0x%x\t0x%x\t0x%x\n' $TotalSize $ProgramSize $DataSize
}

logSelectInfo()
{
	# adjust as desired to log relevant info
	printf "Total\tText\tConst\tOptLvl\tOptForSpeed\tDate\n"
	printf '%d\t%d\t%d\t%s\t%s\t%s\n' $TotalSize $textSize $constSize ${BuildOptLvl} ${BuildOptForSpeedLvl} ${DateNow}
}

parseMapFile()
{
	MapPath="$ProjPath/Debug/${ProjName}.map"

	#parse the size of various segments stored in fram
	persistSizeHex=`awk '/^.TI.persistent/{getline;print $4}' "$MapPath"`
    cinitSizeHex=`awk '/^.cinit/{print $4}' "$MapPath"`
	initarraySizeHex=`awk '/^.init_array/{getline;print $4}' "$MapPath"`
	constSizeHex=`awk '/^.const/{print $4}' "$MapPath"`
	textSizeHex=`awk '/^.text/{print $4}' "$MapPath"`

	crctabSizeHex=`awk '/^.TI.crctab/{getline;print $4}' "$MapPath"`

	brintVecSizeHex=`awk '/^.brintvec/{getline;print $4}' "$MapPath"`
	#echo "brintVecSizeHex = $brintVecSizeHex"

	# not using replaced with reservedSigAndVecSizeHex
	#jtagSigSizeHex=`awk '/^\$fill000/{print $4}' "$MapPath"`
	#bslSigSizeHex=`awk '/^\$fill001/{print $4}' "$MapPath"`
	# Note: because we use 'fill' mechanism to init these sections,
	# the .jtagsignature and .bslsignature sections show as size of 0
	# in the map file, their size can be seen from the $fill000 and $fill001 directives.   
	#jtagSigSizeHex=`awk '/^.jtagsignature/{print $4}' "$MapPath"`
	#bslSigSizeHex=`awk '/^.bslsignature/{print $4}' "$MapPath"`

	resetAddr=`awk '/^.reset/{print $3}' "$MapPath"`

	# On the FR203x series, 0x80 (128 bytes) are reserved for:
	# jtag signature, bsl signature, interrupt vectors, and reset vector.  
	# From addr 0xFF80 - 0xFFFE	
	reservedSigAndVecSizeHex=80	
	# Note - unclear whether program sizes shown by CCS include this section
	#reservedSigAndVecSizeHex=0	
		
	# for programs with proxy tables, no need to count the following section as 
	# it is part of reservedSigAndVecSizeHex.  
	#mainIntVecSizeHex=`awk '/^.mainintvec/{getline;print $4}' "$MapPath"`

	# check for conditions where additional offset should be added to program size estimate
	# parsing map file for the additional sections created in this case would be just as 
	# fragile as hard coding a value below
	#
	# detect if proxy table is being used
    if [ "$resetAddr" == "0000fffe" ]; then
		proxyIntrSizeHex=0
		echo "no proxy table detected"
    else
		# (14 interrupt vectors + 1 reset vector) * 2 bytes each = 30 bytes = 0x1E
		proxyIntrSizeHex=1E
		echo "proxy table detected"
	fi

	# convert hex values to decimal.  
	# Note:  items not found parsing map are converted to 0 here
	persistSize=$((0x$persistSizeHex))
	cinitSize=$((0x$cinitSizeHex))
	initarraySize=$((0x$initarraySizeHex))
	constSize=$((0x$constSizeHex))
	textSize=$((0x$textSizeHex))

	crctabSize=$((0x$crctabSizeHex))
	brintVecSize=$((0x$brintVecSizeHex))
	reservedSigAndVecSize=$((0x$reservedSigAndVecSizeHex))
	proxyIntrSize=$((0x$proxyIntrSizeHex))

	#echo "brintVecSize = $brintVecSize"

	ProgramSize=$(($textSize + $brintVecSize + $reservedSigAndVecSize + $proxyIntrSize))
    DataSize=$(($constSize + $initarraySize + $cinitSize + $persistSize + $crctabSize))

	TotalSize=$(($ProgramSize + $DataSize))

}

parseMakeFile()
{
	makefilePath="$ProjPath/$ProjOutDir/$MakeFileName"

	# search for line containing build command (ie containing cl430)
	# first confirm file format is as we expect - cl430 exists only once

	linecheck=$(grep -c cl430 "$makefilePath")

	if [ "$linecheck" -ne 1 ];then
		echo "warning: found $linecheck lines in makefile containing cl430.  expected 1."
	fi

	buildcmd=$(grep cl430 "$makefilePath")

	# find parameter containing -O0, -O1, -O2, -O3, -O4, -O5, or -Ooff
	optimParam=$(echo "$buildcmd" | awk 'BEGIN{RS=" "}/^-O[0-9o]/{print}')

	optForSpeedLvl=$(echo "$buildcmd" | awk 'BEGIN{RS=" ";FS="="}/^--opt_for_speed/{print $2}')

	#
	# set variables used by rest of script...
	#
	
	BuildCmd="$buildcmd"

	# comma separated for placing into log...
	BuildSymbols=$(echo "$buildcmd" | awk 'BEGIN{RS=" ";FS="=";ORS=","}/^--define/{print $2}')
	
	BuildOptLvl="$optimParam"

	BuildOptForSpeedLvl="$optForSpeedLvl"
}

appendHdrLine()
{
    echo "appending header line to $BuildInfoLogPath"
	logBuildInfoHdr >> "$BuildInfoLogPath"	
}

############################################################
# end of function definitions, begin main execution:
############################################################


# exit script if it encounters an uninitialized variable
set -o nounset

# exit script if any command returns a nonzero value
set -o errexit

# return error if any command in a pipeline fails, instead of using
# return code of last command in pipe.  
set -o pipefail

#uncomment to echo expanded commands for debugging 
#set -x

source vmakeGenBuildInfoCommonSrc

ProjOutDir=Debug
MakeFileName=makefile
IsGetChangsetOpt=false
ProjSrcRelDir="$MSP_SRC_BASE_REL_DIR"

parseArgs "$@"

if [ ! "$IsCCSProj" == true ]; then
    cmdName=$(basename "$0")
	echo "directory not contain code composer studio project, aborting $cmdName"
	exit 1
fi

#
# Variable Init
#
BuildInfoPath="$ProjPath/$BuildInfoFolderName"

BuildInfoLogPath="$BuildInfoPath/$BuildInfoLogFileName"
   	
BuildInfoLabelPath="$BuildInfoPath/$LabelDefaultFileName" 

if [ ! -d "$BuildInfoPath" ]; then
	mkdir "$BuildInfoPath"
	appendHdrLine
fi

DateNow=$(date +%m.%d.%y)
	
TF_PATH="/cygdrive/c/Program Files (x86)/Microsoft Visual Studio 14.0/Common7/IDE/TF.exe"

# colon separated list of file paths to copy, relative to project dir.
FilesToCopy="${ProjOutDir}/${ProjName}.map:${ProjOutDir}/${MakeFileName}:${ProjOutDir}/${ProjName}_linkinfo.xml:.project:.cproject:.ccsproject:${ProjOutDir}/${ProjName}*.hex"

#
# check for flags to execute special behaviors
#

if [ "$DoChangesetOpt" == true ]; then
	findChangeset
	exit 0
fi

if [ "$DoAppendHdr" == true ]; then
	appendHdrLine
	exit 0
fi

if [ "$DoStdOutShort" == true ]; then
	echo "BuildInfo..."
	parseMapFile
	parseMakeFile
	logSelectInfo
	exit 0
fi

if [ "$DoSaveLabel" == true ]; then
	echo "saving label $BuildLabel => $BuildInfoLabelPath"
	echo $BuildLabel > "$BuildInfoLabelPath"	
	exit 0
fi

# set to default value if not obtained via command line (parseArgs)
if [ -z "$BuildLabel" ]; then
	if [ ! -f "$BuildInfoPath/$LabelDefaultFileName" ]; then
		# create default label 'local'
		echo "local" > "$BuildInfoPath/$LabelDefaultFileName"
	fi
	BuildLabel=$(head -n 1 "$BuildInfoPath/$LabelDefaultFileName")
	printf "using default label:\t\t%s\n" "$BuildLabel"
fi

#
# Generate Info
#

loadChangeset
# sets: $Changeset

findUniqFolderName
# sets: $UniqFolderName $UniqFolderPath

printf "creating folder:\t\t%s\n" "$UniqFolderName"
mkdir -p "$BuildInfoPath/$UniqFolderName"

# Note: these symbolic links dont work on cygwin, revisit on mac
#if [ -L "$BuildInfoPath/Latest" ]; then
#	mv "$BuildInfoPath/Latest" "$BuildInfoPath/Prev"
#fi
#ln -snrf "$BuildInfoPath/$UniqFolderName" "$BuildInfoPath/Latest"

parseMapFile
# sets: $ProgramSize

parseMakeFile
# sets: $BuildSymbols, $BuildOptLvl, $BuildOptForSpeedLvl 
	
# Note:  this likely doesn't properly capture symbols being defined to a specific value
echo "$buildcmd" | awk 'BEGIN{RS=" ";FS="=";ORS="\n"}/^--define/{print $2}' > "$UniqFolderPath/BuildSymbols.txt"
	
echo "$buildcmd" > "$UniqFolderPath/BuildCmd.txt"

logBuildInfo >> "$BuildInfoLogPath"
logBuildInfo > "$BuildInfoPath/$UniqFolderName/BuildInfoLogLine.txt"
logVerboseInfo > "$BuildInfoPath/$UniqFolderName/VerboseInfo.txt"
logSelectInfo > "$BuildInfoPath/$UniqFolderName/SelectInfo.txt"

# convert contents of $FilesToCopy string into an array
# Note: with following syntax IFS is only set for the duration of this line
IFS=':' read -ra FilesToCopyArr <<< "$FilesToCopy"

for filepath in ${FilesToCopyArr[@]}; do
    copyFileToUniq "$filepath"
done
