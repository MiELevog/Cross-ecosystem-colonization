#!/bin/bash  # Make sure the script explicitly uses Bash

# Function to display help message (POSIX compatible)
show_help() {
    echo ""
    echo "Description:"
    echo "This Script allows to calculate the total amount of Nitrogen and Carbon per protein"
    echo "within a proteome."	
    echo "Important Notice: Protein file should have the AA sequence written in one single line"
    echo ""
    echo "Author: Microbial Evogenomics Lab (MiEL), University of Zurich, Department of plant and microbial biology, 2024"
    echo ""
    echo ""
    echo "Usage:"
    echo "sh $0 -i <input_file> > <output_file>"
    echo ""
    echo "Options:"
    echo "  -i, --input      Specify the input file containing single lined protein sequences"
    echo "  -h, --help       Display this help message"
    exit 0
}

# Check if no arguments are passed
if [ $# -eq 0 ]; then
    show_help
fi

# Parse command-line options
while [ "$#" -gt 0 ]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -i|--input)
            input_file="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# Check if the input file is provided
if [ -z "$input_file" ]; then
    echo "Error: Input file is required!"
    show_help
fi

# Read the input file passed as an argument
while IFS='' read -r line || [ -n "$line" ]; do
    # Check if this line starts with ">", indicating it's the protein name
    if [ "$(echo ${line} | head -c 1)" = ">" ]; then
        # Print the protein name
        echo ${line} | awk {'print $1'}
        # Set the next flag to 1, indicating the next line will have the amino acids
        next=1
        continue
    fi

    # Process the amino acid sequence line
    if [ "$next" -eq 1 ]; then
        # Reset the next flag
        next=0

        # Count occurrences of each amino acid using grep and wc -l
        A=$(echo "${line}" | grep -o "A" | wc -l)
        R=$(echo "${line}" | grep -o "R" | wc -l)
        N=$(echo "${line}" | grep -o "N" | wc -l)
        D=$(echo "${line}" | grep -o "D" | wc -l)
        C=$(echo "${line}" | grep -o "C" | wc -l)
        E=$(echo "${line}" | grep -o "E" | wc -l)
        Q=$(echo "${line}" | grep -o "Q" | wc -l)
        G=$(echo "${line}" | grep -o "G" | wc -l)
        H=$(echo "${line}" | grep -o "H" | wc -l)
        I=$(echo "${line}" | grep -o "I" | wc -l)
        L=$(echo "${line}" | grep -o "L" | wc -l)
        K=$(echo "${line}" | grep -o "K" | wc -l)
        M=$(echo "${line}" | grep -o "M" | wc -l)
        F=$(echo "${line}" | grep -o "F" | wc -l)
        P=$(echo "${line}" | grep -o "P" | wc -l)
        S=$(echo "${line}" | grep -o "S" | wc -l)
        T=$(echo "${line}" | grep -o "T" | wc -l)
        Y=$(echo "${line}" | grep -o "Y" | wc -l)
        W=$(echo "${line}" | grep -o "W" | wc -l)
        V=$(echo "${line}" | grep -o "V" | wc -l)

        ## Counting the number of Carbons and Nitrogens based on the amino acid composition
        Carbon=$(echo "3*${A} + 3*${C} + 4*${D} + 5*${E} + 9*${F} + 2*${G} + 6*${H} + 6*${I} + 6*${L} + 6*${K} + 5*${M} + 4*${N} + 5*${P} + 5*${Q} + 6*${R} + 3*${S} + 4*${T} + 9*${Y} + 11*${W} + 5*${V}" | bc -l)
        Nitrogen=$(echo "1*${A} + 1*${C} + 1*${D} + 1*${E} + 1*${F} + 1*${G} + 3*${H} + 1*${I} + 1*${L} + 2*${K} + 1*${M} + 2*${N} + 1*${P} + 2*${Q} + 4*${R} + 1*${S} + 1*${T} + 1*${Y} + 2*${W} + 1*${V}" | bc -l)

        # Print out the counts of Carbons and Nitrogens
        printf "Carbons: %s Nitrogens: %s \n" "${Carbon}" "${Nitrogen}"
    fi
done < "$input_file"
