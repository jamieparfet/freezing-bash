#!/bin/bash

# Help function
usage () {
    echo -e "Example: ./convert.sh -i list.b64 -o output.txt"
    echo -e "Options:"
    echo -e "  -i    Input file"
    echo -e "  -o    Output file"
    echo
}

while getopts ":i:o:" option; do
    case "${option}" in
        i) inFile=${OPTARG};;
        o) outFile=${OPTARG};;
        *) usage; exit;;
    esac
done
shift "$((OPTIND-1))"

# Check if arguments are empty
if [ -z "$inFile" ] || [ -z "$outFile" ]; then
    # Print help menu if they are empty
    usage
else

    while read fileline; do
        echo $fileline | base64 -d -i | hexdump -v -e '/1 "%02x" ' >> "$outFile";
        echo "" >> "$outFile";
    done < "$inFile"

fi
