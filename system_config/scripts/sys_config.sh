#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
# SPDX-License-Identifier: MIT

# Exits immediately on failure.
set -eu

# Function to display usage information
usage() {
    echo "Usage: $0 <-c|--config-file CONFIG_FILE> <-p|--param-file PARAM_FILE>"
    echo "Example:"
    echo "  $0 -c /path/to/file/config.yaml -p /path/to/file/params.yaml"
}

# Function to create service directory
#
# Arguments
# * service_name - The name of the service used as the directory name
# * output_dir - Directory to create service dir under
create_service_dir() {
    service_name=$1
    output_dir=$2

    echo "Setting up output directory for $service_name..."
    service_dir="${output_dir}/${service_name}"

    mkdir -p $service_dir
}

# Function to config file from template
#
# Arguments
# * service_directory - The path to the service directory
# * output_dir - Directory to create service dir under
# * file_tempalte - File template to use to create new config file
create_config_file_from_template() {
    service_directory=$1
    output_dir=$2
    file_template=$3

    file_name=$(basename $template)

    echo "Creating config file '$file_name'..."
    out_file="${service_dir}/${file_name}"

    cp $file_template $out_file
}

# Function to get the service config args
#
# Arguments
# * service_name - The name of the service used as the directory name
# * template_index - The index of the template array to search for the service
# * c_file - The system configuration file
# * p_file - The system parameters file
get_service_config_args() {
    service_name=$1
    template_index=$2
    c_file=$3
    p_file=$4

    arg_len=$(yq ".${service_name}[$template_index] | .args | length" $c_file)

    # Iterate over arguments metadata and compile arguments
    for ((n=0;n<$arg_len;n++))
    do
        # Pull argument info from config file
        arg=$(yq ".${service_name}[$template_index] | .args[${n}] | .arg" $c_file)
        params=($(yq ".${service_name}[$template_index] | .args[${n}] | .params" $c_file | tr -d '[],"'))
        optional=$(yq ".${service_name}[$template_index] | .args[${n}] | .optional" $c_file)

        # Replace parameter placeholders
        param_count=1
        add_to_list=true
        for param in "${params[@]}"
        do
            # Get value to pass into argument
            value="${!param:-}"

            # If value is not set, then get value from parameter file
            if [[ -z "${value}" ]]
            then
                value=$(yq ".${param}" $p_file)
            fi

            # If value is still null and param is optional, then break out
            if [[ "${value}" = "null" ]]
            then
                if ! $optional; then echo "Parameter '$param' must be set in parameter file. exiting..." && exit 1; fi
                add_to_list=false
                break
            fi

            # Otherwise, replace param placeholder with value
            value=$(echo "$value" | sed 's,\/,\\/,g')
            arg=$(echo "$arg" | sed 's/{'"$param_count"'}/'"$value"'/g')

            ((param_count++))
        done

        # Add argument to arg list
        if $add_to_list; then
            arg_list+=(${arg})
        fi
    done
}

# Parse command line arguments
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -c|--config-file)
            config_file="$2"
            shift # past argument
            shift # past value
            ;;
        -p|--param-file)
            param_file="$2"
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
if [[ -z "${config_file}" || -z "${param_file}" ]]; then
    echo "Error: Missing required arguments:"
    [[ -z "${config_file}" ]] && echo "  -f|--config-file"
    [[ -z "${param_file}" ]] && echo "  -p|--param-file"
    echo -e "\n"
    usage
    exit 1
fi

# Parse system config file

# Get out directory
out_dir=$(yq '.output_dir' $config_file)

# Get list of services to configure.
services=($(yq '.services ' $config_file | tr -d '[],"'))

# Configure each service based on metadata.
for service in "${services[@]}"
do

    # Create service directory as a sub-directory of the output directory
    create_service_dir $service $out_dir

    num_templates=$(yq ".${service} | length" $config_file)

    for ((t=0;t<$num_templates;t++))
    do
        arg_list=() 
        template=$(yq ".${service}[$t] | .template" $config_file)
        command=$(yq ".${service}[$t] | .command" $config_file)

        # Create config file
        create_config_file_from_template $service $out_dir $template

        echo "Loading parameters..."

        # Argument list for running command for this service
        get_service_config_args $service $t $config_file $param_file

        # execute command
        $command "${arg_list[@]}"
    done
done
