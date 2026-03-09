#!/usr/bin/env bash
CYAN='\x1B[0;36m'
YEL='\x1B[0;33m'
RED='\x1B[0;31m'
NC='\x1B[0m' # No Color

startHelper(){
    echo "${CYAN}Enter first 3 letters of your preferred subtitle language.${NC}"
    echo "${CYAN}Or, press enter to accept 'eng', which is 'english'${NC}"
    read locale
    locale=${locale:-eng}

    echo "Starting Subhelper. Scan path: $1, preferred subtitle language: '$locale'"
    LANGUAGE=$locale watchexec --debounce 2000ms --on-busy-update=do-nothing --emit-events-to=environment -w "$1" -- ruby subhelper.rb
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
    startHelper "$watchPath"
}

promptForInstallWatchexec(){
    echo "Enter y/Y/n/N and press ENTER"
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
        echo "${YEL}Invalid input. Please enter y/Y/n/N and press ENTER${NC}"
        promptForInstallWatchexec
    fi
}

mkdir -p temp/
## cleanup temp directory if needed
temp_dirs_count=$(find temp/ -mindepth 1 -maxdepth 1 -type d | wc -l)
if [ "$temp_dirs_count" -gt "30" ]; then
    echo "Info: Cleaning up temp directory.."
    rm -rf temp/*
fi

if ! [ -x "$(command -v brew)" ]; then
    echo "${RED}This program requires homebrew package manager.${NC}" >&2
    echo "${RED}Please install it first - https://brew.sh/${NC}" >&2
    exit 1
fi

if ! [ -x "$(command -v watchexec)" ]; then
    echo "${CYAN}Watchexec is not installed. Do you want to install it?${NC}" >&2
    promptForInstallWatchexec
else
    promptForWatchPathAndStart
fi