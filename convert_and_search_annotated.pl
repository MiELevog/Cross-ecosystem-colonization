use strict;
use warnings;
use Bio::SeqIO;
use Getopt::Long;

# Variables for command-line arguments
my ($gbk_file, $output_file, $sequence, $help);

# Get command-line arguments with options for help (-h or --help)
GetOptions(
    'input|i=s'    => \$gbk_file,      # Allows --input or -i
    'output|o=s'   => \$output_file,   # Allows --output or -o
    'sequence|s=s' => \$sequence,      # Allows --sequence or -s
    'help|h'       => \$help           # Allows --help or -h
) or die "Usage: $0 --input <INPUT_FILE> --output <OUTPUT_FILE> [--sequence <SEQUENCE>] [--help | -h]\n";

# Display help message if --help or -h option is used
if ($help) {
    print <<"END_HELP";

Description:
This script reads a GenBank file and converts it into a single-line FASTA format. It requires
the BioPerl module Bio::SeqIO to function. The optional argument (--sequence, -s) allows the search within 
the output file for a specific sequence, and reports whether it was found and how many times.
If a sequence is provided, the result will be saved in a file named <OUTPUT_FILE>.sequence_count.txt

Author:
Microbial Evogenomics Lab (MiEL), University of Zurich, Department of plant and microbial biology, 2024.

Options:
--input, -i       Specify the input GenBank file
--output, -o      Specify the output file for the single-line FASTA format
--sequence, -s    Optional: Specify a sequence to search for in the output file and count occurrences
--help, -h        Show this help message, including a description of the script

Usage:
perl $0 --input <INPUT_FILE> --output <OUTPUT_FILE> [--sequence <SEQUENCE>] [--help | -h]

Example:
perl $0 --input example.gbk --output output.fasta --sequence ATGCGT

END_HELP
    exit;
}

# Check if input and output files are provided
die "Usage: $0 --input <INPUT_FILE> --output <OUTPUT_FILE> [--sequence <SEQUENCE>]\n" unless $gbk_file && $output_file;

# Convert GenBank to single-line sequence format
sub convert_to_single_line {
    my ($gbk_file, $output_file) = @_;

    # Read the GenBank file
    my $seq_in = Bio::SeqIO->new(-file => $gbk_file, -format => 'genbank');
    open my $out, '>', $output_file or die "Could not open output file: $!";

    while (my $seq = $seq_in->next_seq) {
        print $out ">", $seq->id, "\n";
        print $out $seq->seq, "\n";
    }
    close $out;
}

# Perform sequence search and count occurrences
sub search_sequence {
    my ($sequence, $output_file) = @_;

    open my $fh, '<', $output_file or die "Could not open file: $!";
    my $file_content = do { local $/; <$fh> };
    close $fh;

    my $matches = 0;
    if ($file_content =~ /$sequence/i) {
        $matches = () = $file_content =~ /$sequence/ig;
        print "Sequence found.\n";
        print "Occurrences: $matches\n";

        # Save result to a file named <output_file>.sequence_count.txt
        my $count_file = "$output_file.sequence_count.txt";
        open my $count_fh, '>', $count_file or die "Could not open count output file: $!";
        print $count_fh "Sequence: $sequence\n";
        print $count_fh "Occurrences: $matches\n";
        close $count_fh;
        print "Result saved to $count_file\n";
    } else {
        print "Sequence not found.\n";
    }
}

# Convert GenBank file
convert_to_single_line($gbk_file, $output_file);

# Search for the sequence if provided
search_sequence($sequence, $output_file) if $sequence;
