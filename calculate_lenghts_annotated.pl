use strict;
use warnings;
use Bio::SeqIO;
use List::Util qw(sum);
use POSIX qw(floor);
use Getopt::Long;

# Variables for command-line arguments
my ($fasta_file, $help);

# Get command-line arguments with options for help
GetOptions(
    'input|i=s' => \$fasta_file,
    'help|h'    => \$help,
) or die "Usage: $0 --input INPUT_FILE [--help]\n";

# Display help message if --help option is used
if ($help) {
    print <<"END_HELP";

Description:
This script reads a multi-FASTA file (nucleotide or amino acid) and calculates the total number of sequences, the mean length of sequences, and the median length of sequences. It requires the BioPerl module Bio::SeqIO to function.

Author: 
Microbial Evogenomics Lab (MiEL), University of Zurich, Department of plant and microbial biology, 2024

Options:
--input,-i       Specify the input multi-FASTA file
--help, -h        Show this help message

Usage: $0 --input <INPUT_FILE> [--help]

END_HELP
    exit;
}

# Check if input file is provided, otherwise display usage and exit
die "Usage: $0 --input INPUT_FILE\n" unless $fasta_file;

# Read the multi-FASTA file
my $seq_in = Bio::SeqIO->new(-file => $fasta_file, -format => 'fasta');
my @lengths;

while (my $seq = $seq_in->next_seq) {
    push @lengths, $seq->length;
}

# Calculate mean length
my $total = sum(@lengths);
my $mean = $total / @lengths;

# Calculate median length
@lengths = sort { $a <=> $b } @lengths;
my $median;
if (@lengths % 2 == 0) {
    $median = ($lengths[@lengths/2 - 1] + $lengths[@lengths/2]) / 2;
} else {
    $median = $lengths[floor(@lengths/2)];
}

# Print results
print "Total sequences: ", scalar @lengths, "\n";
print "Mean length: $mean\n";
print "Median length: $median\n";
