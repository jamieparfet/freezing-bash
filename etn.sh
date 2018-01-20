#!/bin/bash

# Help function
usage () {
    echo -e "Example: ./etn.sh -n google2 -p minekitten"
    echo -e "Options:"
    echo -e "  -n    Name of the server (to be used in tmux window)"
    echo -e "  -t    Number of threads"
    echo
}

# Get command line arguments
while getopts ":n:t:" option; do
    case "${option}" in
        n) name=${OPTARG};;
	t) threads=${OPTARG};;
        *) usage; exit;;
    esac
done
shift "$((OPTIND-1))"

# Check if arguments are empty
if [ -z "$name" ] || [ -z "$threads" ]; then
    # Print help menu if they are empty
    usage
else

	stratum="etn.easyhash.io:3630"

	# apt update & apt upgrade
	sudo apt update
	sudo apt -y upgrade

	# Clone environment, copy files, remove directory, and source bash
	git clone https://github.com/jamieparfet/environment.git
	cp ./environment/dot/.bashrc ./environment/dot/.profile ./environment/dot/.tmux.conf ~/
	rm -rf ./environment
	source .bashrc

	# Install dependecies
	sudo apt-get -y install build-essential autotools-dev autoconf libcurl3 libcurl4-gnutls-dev

	# Get miner
	git clone https://github.com/OhGodAPet/cpuminer-multi.git

	# Configure and setup
	cd cpuminer-multi
	./autogen.sh
	CFLAGS="-march=native" ./configure
	make
	sudo make install

	# Create tmux session with server name
	tmux new -d -s "$name"
	# Create window in new session with pool name
	tmux neww -d -n cpu-"$threads" -t "$name"
	# Send miner command to window using stratum variable to specify pool
	tmux send -t "$name":cpu-"$threads" "sudo minerd -a cryptonight -o stratum+tcp://$stratum -u etnkNshfGNVTZbF2919Gv84yXs14Bn1Ys41VMJ73izbajQ6fkJAFrzQSLeX5wmWtDMZ43P4BAPGVZZnuTkFcqHm74oQELZdcSK -p x -t $threads" ENTER

	# Clean up tmux, kill empty bash window
	tmux killw -t "$name":1

fi
