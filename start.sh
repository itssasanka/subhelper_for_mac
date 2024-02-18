#!/usr/bin/env bash
CYAN='\x1B[0;36m'
YEL='\x1B[0;33m'
RED='\x1B[0;31m'
NC='\x1B[0m' # No Color

startHelper(){
    echo "Starting Subhelper. Scan path: $1"
    LANGUAGE=eng watchexec --on-busy-update=do-nothing -f '*untitled*' -f '*.srt' -f '*.zip' \
    -w $1 ruby subhelper.rb
}

promptForWatchPathAndStart(){
    echo "======================================================="
    echo "${CYAN}Enter parent path to scan or press ENTER to accept $HOME/Downloads${NC}"
    read watchPath
    watchPath=${watchPath:-$HOME/Downloads}

    if [ ! -d "$watchPath" ]; then
        echo "Fatal error: $watchPath does not exist."
        echo "${RED}Quitting program${NC}"
        exit 1
    fi
    startHelper $watchPath
}

promptForInstallWatchexec(){
    echo "Enter y/Y/n/N"
    read installWatchexec
    
    if [ "$installWatchexec" = "y" ] || [ "$installWatchexec" = "Y" ]; then
        echo "${YEL} Installing watchexec.. ${NC}"
        brew install watchexec
        promptForWatchPathAndStart
    elif [ "$installWatchexec" = "n" ] || [ "$installWatchexec" = "N" ]; then
        echo "Subhelper needs watchexec to work."
        echo "${YEL}Quitting program..${NC}"
        exit 1
    else
        echo "${YEL}Invalid input. Please enter y/Y/n/N${NC}"
        promptForInstallWatchexec
    fi
}

mkdir -p temp/
## cleanup temp directory if needed
temp_dirs_count=$(ls -d temp/ | wc -l)
if [ "$temp_dirs_count" -gt "30" ]; then
    echo "Info: Cleaning up temp directory.."
    rm -rf temp/**
fi

if ! [ -x "$(command -v brew)" ]; then
    echo "${RED}This program requires homebrew package manager.${NC}" >&2
    echo "${RED}Please install it first - https://brew.sh/${NC}" >&2
    exit
fi

if ! [ -x "$(command -v watchexec)" ]; then
    echo "${CYAN}Watchexec is not installed. Do you want to install it?${NC}" >&2
    promptForInstallWatchexec
else
    promptForWatchPathAndStart
fi