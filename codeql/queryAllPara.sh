#!/bin/bash

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <directory> <file> <reportPath> <num_parallel> <startID>"
    exit 1
fi

directory=$1
file=$2
report=$3
num_parallel=$4 
startID=$5

if [ ! -d "$directory" ]; then
    echo "Directory $directory does not exist."
    exit 1
fi

# output folder
if [ ! -d "${directory}/${report}" ]; then
    mkdir "${directory}/${report}"
fi

if [ ! -e "$file" ]; then
    echo "[!] Can not find the codeQL script"
    exit 2
fi

function handle_interrupt {
    echo "Script interrupted. Cleaning up..."
    exit 1
}

trap handle_interrupt SIGINT

count=0
for entry in "$directory"/*; do

    if [ -f "$entry" ] && [[ "$entry" == *.zip ]]; then
        ((count++))
        if [ $count -le $startID ]; then
            name=$(basename "$entry")
            echo "[*]Skip ${count}: ${name}"
            continue  #skip
        fi
        (
            filepath="${entry%.zip}"
            filename=$(basename "$entry" .zip)
            target_directory="${filepath}.temp"
            unzip -q "${entry}" -d "${target_directory}"

            reportPath="${directory}/${report}/${filename}.csv"
            echo "[*] ID: ${count} Writing to ${reportPath}"

            #some folder's called java rather than  codeql_db
            codeql database analyze "${target_directory}/java" "${file}" --format=csv --output="${reportPath}"
            if ! grep -q '[^[:space:]]' "${reportPath}"; then
                rm "${reportPath}"
            fi
            rm -rf "${target_directory}"
        ) &
        if (( count % num_parallel == 0 )); then
            wait  
        fi
    fi
done

wait  
echo "[*] Operation completed."
