#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
# SPDX-License-Identifier: MIT

# Exits immediately on failure.
set -eu

# Function to display usage information
usage() {
    echo "Usage: $0 <-f|--file FILE> <-p|--param PARAM_NAME="PARAM_VALUE"> [-p|--param PARAM_NAME="PARAM_VALUE"]..."
    echo "Example:"
    echo "  $0 -f /path/to/file/config.yaml -p param1=value1 -p param2=value2..."
}

# Create param list
param_list=()

# Parse command line arguments
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -f|--file)
            file="$2"
            shift # past argument
            shift # past value
            ;;
        -p|--param)
            param_list+=("$2")
            shift # past argument
            shift # past value
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $key"
            usage
            exit 1
    esac
done

# Check if all required arguments have been set
if [[ -z "${file}" || ${#param_list[@]} -eq 0 ]]; then
    echo "Error: Missing required arguments:"
    [[ -z "${file}" ]] && echo "  -f|--file"
    [[ ${#param_list[@]} -eq 0 ]] && echo "  -p|--param"
    echo -e "\n"
    usage
    exit 1
fi

# Uncomment any commented out entries following the pattern
# '(#\s)(.*:(\s<<value>>)?)$' so the file can be properly processed
sed -i -e 's/\(#[[:space:]]\)\(.*:\([[:space:]]<<value>>\)\?\)$/\2/g' $file

for i in "${param_list[@]}"
do
    # Split entry into name and value
    IFS='=' read name value <<< "${i}"

    # Set param in file, will leave a null entry if param is not present in
    # config file
    yq -i "with((.${name} | select(. == \"<<value>>\")) ; . = \"${value}\" | . style=\"double\")" ${file}
done

# Remove any unpopulated/null values. Will clean up any parents that have no
# children
yq -i 'del(.. | select(. == "<<value>>")), del(.. | select(. | length == 0))' ${file}

# Strip comments. yq does not handle comments very well and leaving comments in
# after deletion could cause confusion
yq -i '... comments=""' ${file}

# Add header to indicate the config file was made by a script
yq -i '. head_comment = "Generated configuration file"' ${file}
