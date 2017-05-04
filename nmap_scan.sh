#!/bin/bash

DATE=$(date +%Y-%m-%d)
FILES="/root/Desktop/test-ping-results"
SAVEPATH="/root/Desktop/${DATE}_ScanResults"

# Function to run nmap scan from fping results
function runscan {
	# Loop through fping result files
	for filename in "${FILES}"/*.txt; do

		# Replace fping with version and remove .txt extension
		stripped="$(echo ${filename} | sed 's/fping/version/g' | sed 's/\.txt$//')"
		# Get base file name
		baseFile="${stripped##*/}"

		# Run nmap command
		# filename is fping.txt file and baseFile is nmap results name
		echo "CMD: nmap -v -sV -iL ${filename} -oX ${SAVEPATH}/${baseFile}.xml"
	done
}

# Check for output directory
if [ ! -d "${SAVEPATH}" ]
then
	# if it does not exist, create dir and execute runscan function
	mkdir "${SAVEPATH}"
	runscan
else
	# if it does exist, just runscan
	runscan
fi
