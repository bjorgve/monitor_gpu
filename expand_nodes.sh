#!/bin/bash

# Function to expand the node range like "nid[005252-005254]" into individual nodes
expand_node_range() {
    local node_range=$1
    if [[ "$node_range" == *"["* ]]; then
        local prefix=${node_range%%[*]}          # Extract the prefix ending at the first '['
        local range_numbers=${node_range#*[}     # Extract the range numbers
        range_numbers=${range_numbers%]*}        # Remove the trailing ']'

        local IFS='-'
        read -r start end <<< "$range_numbers"   # Read the start and end numbers of the range

        # Use printf to generate the sequence with zero padding based on the width of the numbers
        local width=${#start}
        for (( i=10#$start; i <= 10#$end; i++ )); do
            echo $(printf "nid%0${width}d" $i)
        done
    else
        echo "$node_range"
    fi
}
# Check if an argument was provided
if [ $# -eq 1 ]; then
    # Call the function with the provided argument
    expand_node_range "$1"
else
    echo "Usage: $0 <node_range>"
    exit 1
fi
