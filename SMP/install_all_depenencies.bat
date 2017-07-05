@ECHO OFF
SETLOCAL EnableDelayedExpansion

SET INSYASMBAT=install_yasm.bat
SET INSDEPBAT=project_get_dependencies.bat

REM Store current directory and ensure working directory is the location of current .bat
SET CURRDIR=%CD%
cd %~dp0

REM Initialise error check value
SET ERROR=0

set DEPDIR=dependencies\
IF not exist %DEPDIR%\ (mkdir %DEPDIR%)

REM Install YASM
CALL %INSYASMBAT% || GOTO exitOnError

REM Install dependent projects
CALL %INSDEPBAT% || GOTO exitOnError

:exitOnError
cd %CURRDIR%
SET ERROR=1

:return
EXIT /B %ERROR%