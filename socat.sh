#!/bin/bash

# Help function
usage () {
    echo -e "Example: ./socat.sh -d 192.168.1.1 -p 80,443,8080"
    echo -e "Options:"
    echo -e "  -d    Destination IP address"
    echo -e "  -p    TCP ports to forward (comma seperated)"
    echo
}

check_env () {
    # Check if tmux is installed
    if [ $(which tmux) ]; then
        echo "[+] Tmux is installed"
    else
        echo "[ERROR] Tmux is not installed"
        exit 1
    fi

    # Check if a socat session exists
    if [ $(tmux ls -F '#{session_name}' | grep -c 'socat') -eq 0 ]; then
        echo "[+] No tmux sessions named socat are running"
        echo
    else
        echo "[ERROR] A socat session might already be running"
        exit 1
    fi
}

# Get command line arguments
while getopts ":d:p:" option; do
    case "${option}" in
        d) destination=${OPTARG};;
        p) ports=${OPTARG};;
        *) usage; exit;;
    esac
done
shift "$((OPTIND-1))"

# Check if arguments are empty
if [ -z "$destination" ] || [ -z "$ports" ]; then
    # Print help menu if they are empty
    usage
else
    # Run the check environment function
    check_env

    echo "Destination: ${destination}"

    # Create new session named socat
    tmux new -d -s socat

    # Loop through ports split by comma
    for i in $(echo $ports | sed "s/,/ /g")
    # Create new windows within socat session
    do
        tmux neww -d -n "$i" -t socat
        tmux send -t socat:"$i" "socat TCP4-LISTEN:$i,fork TCP4:${destination}:$i" ENTER
        echo "[*] Forwarding port $i"
    done

    # Kill first blank tmux window
    tmux killw -t socat:1
    # List windows in socat session
    echo
    echo "Current windows in session \"socat\":"
    tmux lsw -t socat

    # TO DO - Advanced formatting
    # tmux lsw -t socat -F '#{window_id} #{window_name}'
fi
