#!/bin/bash


if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <directory> <file> <reportPath>"
    exit 1
fi


directory=$1
file=$2
report=$3


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


for entry in "$directory"/*; do
    if [ -f "$entry" ] && [[ "$entry" == *.zip ]]; then
        filepath="${entry%.zip}"
        filename=$(basename "$entry" .zip)
        target_directory="${filepath}.temp"
        unzip -q "${entry}" -d "${target_directory}"

        reportPath="${directory}/${report}/${filename}.csv"
        echo "[*] Writing to ${reportPath}"

        codeql database analyze "${target_directory}/codeql_db" "${file}" --format=csv --output="${reportPath}"
        if ! grep -q '[^[:space:]]' "${reportPath}"; then
            rm "${reportPath}"
        fi
        rm -rf "${target_directory}"
    fi
done

echo "[*] Operation completed."
