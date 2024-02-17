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
    read -p "Enter parent path to scan or press ENTER to accept $HOME/Downloads " watchPath
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

## cleanup temp directory
# find subhelper -type d | wc -l


if ! [ -x "$(command -v watchexec)" ]; then
    echo "${CYAN}Watchexec is not installed. Do you want to install it?${NC}" >&2
    promptForInstallWatchexec
else
    promptForWatchPathAndStart
fi