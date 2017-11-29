#!/bin/bash

# Help function
usage () {
echo -e "Example: ./adv-socat.sh -d 192.168.1.1 -p 80,443,8080"
echo -e "Options:"
echo -e "  -d    Destination IP address"
echo -e "  -p    TCP ports to forward (comma seperated)"
echo
}

# Get command line arguments
while getopts ":d:p:" option; do
    case "${option}" in
        d) destination=${OPTARG};;
        p) port=${OPTARG};;
        *) usage; exit;;
    esac
done
shift "$((OPTIND-1))"

# Check if arguments are empty
if [ -z "$destination" ] || [ -z "$port" ]; then
    # Print help menu if they are empty
    usage
else
    echo "Destination: ${destination}"

    # Create new session named socat
    tmux new -d -s socat

    # Split ports by comma
    port_list=$port
    for i in $(echo $port_list | sed "s/,/ /g")
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
