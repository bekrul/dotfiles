::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 2017 - Ben Krulewitch
::
:: mspmake.bat - build a Code Composer Studio 6 project using gmake.  
::
:: gmake is the command line tool invoked by the CCS6 IDE. 
:: Build options are altered from the project settings by specifying 
:: a command file via an environment variable.  This allows build errors
:: to be sent to a file when building from command line and sent to the IDE 
:: when building within that environment.  
:: 
:: Requires: windows gmake installed by CCSv6 is part of the windows path
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: silent operation
::@ECHO OFF

:: make changes to the environment local to this script
SETLOCAL

SET ScriptDir=%~dp0

:: Note: 'comments' of this style are not allowed within if block (thanks dos!)

:: default to build all, unless user passes in a rule
if [%1]==[] (
    SET MakeRule=all
) ELSE (
    SET MakeRule=%1
)

::ECHO "Execution Dir: %CD%"

::ECHO "MakeRule:  %MakeRule%"

:: Use command file to pass flags to compiler - did not work from dos
::set MSP430_C_OPTION=--cmd_file=%ScriptDir%GblCmdLineBuildOptsCCS6.txt

:::::::::::: Begin Compiler Options ::::::::::::::::::::::::::::::::::::::::::::

:: I have not had success getting options set with --cmd_file passed to compiler 
:: So, just pass in the options directly via environment variable.  
set MSP430_C_OPTION=--write_diagnostics_file
:: same command, also works...
::set MSP430_C_OPTION=-pdf

:: suppress ULP power advisor warnings (use IDE to view this advice)
set MSP430_C_OPTION=%MSP430_C_OPTION% --advice:power=none

:::::::::::: END Compiler Options ::::::::::::::::::::::::::::::::::::::::::::::

:: always echo the gmake command
@ECHO ON
:: Note, could use -C DIRECTORY to set the directory that gmake is executed from,
:: but it's been simpler to just require this script is executed from project directory.  
gmake -k %MakeRule%
@ECHO OFF
set GMAKE_ERR_LVL=%errorlevel%

:: end localized environment
ENDLOCAL & SET _GMAKE_ERR_LVL=%GMAKE_ERR_LVL%

exit /B %_GMAKE_ERR_LVL%

