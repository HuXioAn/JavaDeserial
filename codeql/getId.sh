#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory> <fileName>"
    exit 1
fi

directory=$1
fileName=$2  

count=0
for entry in "$directory"/*; do
    if [ -f "$entry" ]; then
        ((count++))
    
        entryName=$(basename "$entry")

        if [[ "$entryName" == "$fileName" ]]; then
            echo "${fileName}: ${count}"
            exit 0
        fi
    fi
done

echo "Cannot find ${fileName} in the directory."
