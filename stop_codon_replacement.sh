#!/bin/bash

# Description:
# This script processes all FASTA files in a specified directory, removing stop codons 
# (TAA, TAG, TGA) from the end of sequences. It modifies the input files directly.
#
# Usage:
# ./script_name.sh --dir <directory_with_fasta_files>
#
# Options:
# --dir      Specify the directory containing FASTA files (required).
# --help     Display this help message and exit.

# Function to display usage/help
usage() {
    echo "Description:"
    echo "  This script processes FASTA files in a given directory and removes any stop codons"
    echo "  (TAA, TAG, TGA) found at the end of sequences. The original files are overwritten"
    echo "  with the modified content."
    echo
    echo "Author: Microbial Evogenomics Lab (MiEL), University of Zurich, Department of plant and microbial biology, 2024"
    echo
    echo "Usage:"
    echo "  $0 --dir <directory_with_fasta_files>"
    echo
    echo "Options:"
    echo "  --dir      Specify the directory containing FASTA files (required)."
    echo "  --help     Display this help message and exit."
    exit 0
}

# Parse command-line arguments
while [ "$#" -gt 0 ]; do
    case $1 in
        --dir) FASTA_DIR="$2"; shift ;;
        --help) usage ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Check if the directory is provided
if [ -z "$FASTA_DIR" ]; then
    echo "Error: Directory not specified."
    usage
fi

# Check if the directory exists
if [ ! -d "$FASTA_DIR" ]; then
    echo "Error: Directory $FASTA_DIR does not exist."
    exit 1
fi

# Define the stop codons (TAA, TAG, TGA)
stop_codons=("TAA" "TAG" "TGA")

# Process each FASTA file in the directory
for fasta_file in "$FASTA_DIR"/*.{fna,fas,fasta}; do
    # Check if the file exists (to avoid errors if no files match)
    if [ ! -f "$fasta_file" ]; then
        continue
    fi

    echo "Processing $fasta_file..."

    # Create a temporary file to store the processed content
    tmp_file=$(mktemp)

    # Process each sequence in the FASTA file
    while IFS= read -r line; do
        if echo "$line" | grep -q "^>"; then
            # If the line is a header, write it directly to the temp file
            echo "$line" >> "$tmp_file"
        else
            # If the line is a sequence, check the last three nucleotides
            last_triplet=${line: -3}
            if echo "${stop_codons[@]}" | grep -qw "$last_triplet"; then
                # Delete the stop codon at the end
                new_sequence="${line:0:-3}"
                echo "$new_sequence" >> "$tmp_file"
            else
                # Write the sequence unchanged if no stop codon is found at the end
                echo "$line" >> "$tmp_file"
            fi
        fi
    done 
