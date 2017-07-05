@ECHO OFF
SETLOCAL EnableDelayedExpansion

SET UPSTREAMURL=https://github.com/ShiftMediaProject
SET VSYASM=VSYASM

REM Check if git is installed and available
IF "%MSVC_VER%"=="" (
    git status >NUL 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        ECHO A working copy of git was not found. To use this script you must first install git for windows.
        GOTO exitOnError
    )
)

REM Store current directory and ensure working directory is the location of current .bat
SET CURRDIR=%CD%
cd %~dp0

REM Initialise error check value
SET ERROR=0

set DEPDIR=dependencies\
IF not exist %DEPDIR%\ (mkdir %DEPDIR%)
cd %DEPDIR%\

REM Function to clone or update a repo
REM  cloneOrUpdateRepo: RepoName
REM    RepoName = Name of the repository
:cloneOrUpdateRepo
SET REPONAME=%VSYASM%
REM Check if the repo folder already exists
IF EXIST "%REPONAME%" (
    ECHO %REPONAME%: Existing folder found. Checking for updates...
    cd %REPONAME%
    REM Check if any updates are available
    FOR /f %%J IN ('git rev-parse HEAD') do set CURRHEAD=%%J
    FOR /f %%J IN ('git ls-remote origin HEAD') do set ORIGHEAD=%%J
    IF "!CURRHEAD!"=="!ORIGHEAD!" (
        ECHO %REPONAME%: Repository up to date.
    ) ELSE (
        REM Stash any uncommited changes then update from origin
        ECHO %REPONAME%: Updates available. Updating repository...
        git checkout master --quiet
        git stash --quiet
        git pull origin master --quiet -ff
        git stash pop --quiet
    )
) ELSE (
    ECHO %REPONAME%: Existing folder not found. Cloning repository...
    REM Clone from the origin repo
    SET REPOURL=%UPSTREAMURL%/%REPONAME%.git
	REM git clone !REPOURL! --quiet
	git clone !REPOURL!
    IF %ERRORLEVEL% NEQ 0 (
        ECHO %REPONAME%: Git clone failed.
        GOTO exitOnError
    )
    REM Initialise autocrlf options to fix cross platform interoperation
    REM  Once updated the repo needs to be reset to correct the local line endings
    cd %REPONAME%
    git config --local core.autocrlf false
    git rm --cached -r . --quiet
    git reset --hard --quiet
)

REM Install YASM
SET INSTALLFILE=install_script.bat
ECHO %INSTALLFILE%: Install YASM
@ECHO | CALL %INSTALLFILE% >NUL 2>&1 || GOTO exitOnError
GOTO RETURN

:exitOnError
cd %CURRDIR%
SET ERROR=1

:return
EXIT /B %ERROR%