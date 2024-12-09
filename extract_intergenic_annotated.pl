use strict;
use warnings;
use Bio::SeqIO;
use Getopt::Long;

# Variables for command-line arguments
my ($gbk_file, $output_file, $help);

# Get command-line arguments with options for help (-h or --help)
GetOptions(
    'input|i=s'  => \$gbk_file,        # Allows --input or -i
    'output|o=s' => \$output_file,     # Allows --output or -o
    'help|h'     => \$help             # Allows --help or -h
) or die "Usage: $0 --input <INPUT_FILE> --output <OUTPUT_FILE> [--help | -h]\n";

# Display help message if --help or -h option is used
if ($help) {
    print <<"END_HELP";

Description:
This script identifies and  extracts intergenic regions from a GenBank file and saves them as FASTA entries in the specified output file.
The script iterates through each gene in the GenBank file and extracts the sequences between genes as intergenic regions. It also verifies whether each intergenic region is present in 
the full sequence.

Author:
Microbial Evogenomics Lab (MiEL), University of Zurich, Department of plant and microbial biology, 2024.

Options:
--input, -i       Specify the input GenBank file
--output, -o      Specify the output file for intergenic regions in FASTA format
--help, -h        Show this help message, including a description of the script

Usage:
perl $0 --input <INPUT_FILE> --output <OUTPUT_FILE> [--help | -h]

Example:
perl $0 --input example.gbk --output intergenic_regions.fasta

END_HELP
    exit;
}

# Check if input and output files are provided
die "Usage: $0 --input <INPUT_FILE> --output <OUTPUT_FILE> [--help | -h]\n" unless $gbk_file && $output_file;

# Function to extract intergenic regions and write them to the output file
sub extract_intergenic_regions {
    my ($gbk_file, $output_file) = @_;

    # Read the GenBank file
    my $seq_in  = Bio::SeqIO->new(-file => $gbk_file, -format => 'genbank');
    my $seq_out = Bio::SeqIO->new(-file => ">$output_file", -format => 'fasta');

    while (my $seq = $seq_in->next_seq) {
        my $previous_end = 0;
        my $sequence_id = $seq->id;
        my $full_sequence = $seq->seq;

        # Collect gene features sorted by start position
        my @features = sort { $a->start <=> $b->start } grep { $_->primary_tag eq 'gene' } $seq->get_SeqFeatures;

        # Loop through each feature to find intergenic regions
        for my $i (0..$#features) {
            my $feature = $features[$i];
            my $start = $feature->start;

            # Check if there is an intergenic region between genes
            if ($previous_end < $start - 1) {
                my $intergenic_region = $seq->subseq($previous_end + 1, $start - 1);
                my $intergenic_id = "${sequence_id}_intergenic_" . ($previous_end + 1) . "_" . ($start - 1);
                $seq_out->write_seq(Bio::Seq->new(-id => $intergenic_id, -seq => $intergenic_region));

                # Verify the intergenic region in the full sequence
                if (index($full_sequence, $intergenic_region) != -1) {
                    print "Match found in GenBank file for $intergenic_id\n";
                } else {
                    print "No match found in GenBank file for $intergenic_id\n";
                }
            }
            $previous_end = $feature->end;
        }

        # Handle the region after the last gene to the end of the sequence
        if ($previous_end < $seq->length) {
            my $intergenic_region = $seq->subseq($previous_end + 1, $seq->length);
            my $intergenic_id = "${sequence_id}_intergenic_" . ($previous_end + 1) . "_" . $seq->length;
            $seq_out->write_seq(Bio::Seq->new(-id => $intergenic_id, -seq => $intergenic_region));

            # Verify the intergenic region in the full sequence
            if (index($full_sequence, $intergenic_region) != -1) {
                print "Match found in GenBank file for $intergenic_id\n";
            } else {
                print "No match found in GenBank file for $intergenic_id\n";
            }
        }
    }
}

# Call the subroutine with the provided arguments
extract_intergenic_regions($gbk_file, $output_file);
