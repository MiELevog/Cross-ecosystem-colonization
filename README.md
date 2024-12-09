# Cross-ecosystem-colonization
This repository contains custom Perl and Bash scripts used for the following paper "Deep-branching Chloroflexota linages illuminate the eco-evolutionary foundation of cross-ecosystem colonization".

# calculate_lengths_annotated.pl : 
This script reads a multi-FASTA file (nucleotide or amino acid) and calculates the total number of sequences, the mean length of sequences, and the median length of sequences. It requires the BioPerl module Bio::SeqIO to function.

# Carbonara.sh: 
This Script allows to calculate the total amount of Nitrogen and Carbon per protein within a proteome.
Important Notice: Protein file should have the AA sequence written in one single line.

# codon_usage.pl: 
The script reads coding DNA sequences from multi-FASTA files and counts the occurrences of all 64 possible codons by iterating through the sequences in frames of three nucleotides. The total counts for each codon are then normalized by dividing by the total number of codons in each genome, resulting in codon frequency values. The script outputs a tab-delimited file where each row corresponds to a codon and each column represents the codon frequencies for a particular genome.

# convert_and_search_annotated.pl: 
This script reads a GenBank file and converts it into a single-line FASTA format. It requires
the BioPerl module Bio::SeqIO to function. The optional argument (--sequence, -s) allows the search within 
the output file for a specific sequence, and reports whether it was found and how many times.
If a sequence is provided, the result will be saved in a file named <OUTPUT_FILE>.sequence_count.txt

# extract_intergenic_annotated.pl: 
This script identifies and  extracts intergenic regions from a GenBank file and saves them as FASTA entries in the specified output file. The script iterates through each gene in the GenBank file and extracts the sequences between genes as intergenic regions. It also verifies whether each intergenic region is present in the full sequence.

# stop_codon_remplacement.sh: 
This script processes all FASTA files in a specified directory, removing stop codons (TAA, TAG, TGA) from the end of sequences. It modifies the input files directly.
