#!/bin/bash

# Help function
usage () {
    echo -e "Example: ./coinhive.sh -n google5 -k MNQ2OqpvrjWDNAjCHfjePvxUlwOWPFZr"
    echo -e "Options:"
    echo -e "  -n    Name of the server (to be used in tmux window)"
    echo -e "  -k    Coinhive public site key"
    echo
}

# Get command line arguments
while getopts ":n:k:" option; do
    case "${option}" in
        n) name=${OPTARG};;
        k) key=${OPTARG};;
        *) usage; exit;;
    esac
done
shift "$((OPTIND-1))"

# Check if arguments are empty
if [ -z "$name" ] || [ -z "$key" ]; then
    # Print help menu if they are empty
    usage
else

	# apt update & apt upgrade
	sudo apt update
	sudo apt -y upgrade

	# clone environment
	git clone https://github.com/jamieparfet/environment.git
	cp ./environment/dot/.bashrc ./environment/dot/.profile ./environment/dot/.tmux.conf ~/
	rm -rf ./environment

	# Install node and dependencies
	curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
	sudo apt install -y nodejs libgtk-3-0 libgconf-2-4 libpangocairo-1.0-0 chromium-browser chromium-bsu htop tmux

	# Install coin-hive command line miner
	sudo npm i -g coin-hive --unsafe-perm=true --allow-root

	# Use env
	source .bashrc

	# Create tmux session called coin
	tmux new -d -s coin
	# Create window in coin called $name
	tmux neww -d -n "$name" -t coin
	# Send command to coin window
	tmux send -t coin:"$name" "sudo coin-hive $key" ENTER
	# Get htop going
	tmux neww -d -n htop -t coin
	tmux send -t coin:htop "htop" ENTER

fi
