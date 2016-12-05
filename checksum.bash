#!/bin/bash
# Compute a checksum on all files in a directory
# or verify checksums specified in a file

# Function to compute checksums
function compute {
	for directory in $input
	do
		# If the input is a dir and ends with /
		if [ -d ${directory} ] && [ ${directory: -1} == "/" ]
		then
			# Find all files in the directory and preform MD5
			for files in $(find ${directory}* -maxdepth 0 -type f)
			do
				md5sum ${files}
			done

		# If the input is a dir and does not end with /
		elif [ -d ${directory} ] && [ ${directory: -1} != "/" ]
		then
			# Append / to directory name and preform MD5 on all files
			for files in $(find ${directory}/* -maxdepth 0 -type f)
                        do
                                md5sum ${files}
                        done
		fi
	done
}

# Initial menu
echo "Would you like to compute or verify checksums?"
echo ""
printf "%-5s [1] compute\n"
printf "%-5s [2] verify\n"
echo ""

# Get user response
read -p "Please enter a number to select an option: " -n 1 -r
echo ""
echo ""

# If option 1 is selected, compute a checksum
if [[ $REPLY =~ ^[1]$ ]]
then
	echo "Please specify one or more directories to compute an MD5 checksum on."
	echo "If selecting multiple directories, seperate them with a space."

	# Read the input as a string using internal field seperator
	IFS= read -e -r -p "Directories: " input
	echo ""
	for directory in $input
        do
                if [ ! -d ${directory} ]
		then
			echo "Error: ${directory} is not a directory."
			exit 1
		fi
	done

	# Ask where to save the file
	echo "Where do you want save the checksum file?"
	read -e -p "Location: " saveFile

	# If the file exists, prompt the user to continue
	if [ -f "${saveFile}" ]
	then
		echo "${saveFile} already exists."
		echo "Do you want to overwrite the file or append the new checksums to the end?"
		echo ""
		printf "%-5s [1] overwrite\n"
		printf "%-5s [2] append\n"
		printf "%-5s [3] exit\n"
		echo ""

		# Get user response
		read -r -p "Please enter a number to select an option: "
		echo ""

		# If user selects option 1, execute compute function and overwrite file
		if [[ $REPLY =~ ^[1]$ ]]
		then
			echo "Overwriting file..."
			compute > ${saveFile}
			echo "New file saved: ${saveFile}"
			echo ""

		# If user selects option 2, execute compute function and append checksums to existing file
		elif [[ $REPLY =~ ^[2]$ ]]
		then
			echo "Appending checksums to existing file..."
			compute >> ${saveFile}
			echo "File updated: ${saveFile}"
			echo ""

                # If user selects option 3, exit the script
                elif [[ $REPLY =~ ^[3]$ ]]
                then
                        echo "Exiting..."
                        echo ""
                        exit 1
                fi

	# If the file does not exist, execute compute function and save the new file
	else
		echo "Creating file..."
		compute > ${saveFile}
		echo "New file saved: ${saveFile}"
		echo ""
	fi


# If option 2 is selected, verify a checksum
elif [[ $REPLY =~ ^[2]$ ]]
then
	echo "Please specify the file containing the checksums."
	read -e -p "Location: " verFile

	# Check to see if file exists
	if [ -f "${verFile}" ]
	then
		echo ""
		# Preform MD5 with verify option
		(md5sum -c ${verFile})
		echo ""
	else
		# If file does not exist, throw error and exit script
		echo "Error: ${verFile} does not exist or it is not a valid file."
		echo ""
		exit 1
	fi

# If neither option is selected, exit the script
else
	exit 1
fi
