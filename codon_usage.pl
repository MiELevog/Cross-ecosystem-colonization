use strict;
use warnings;
use Bio::SeqIO;
use Getopt::Long;
use List::Util qw(sum);
use File::Basename;

# Get command-line arguments
my ($input_dir, $output_file, $help);
GetOptions(
    'input|i=s'  => \$input_dir, # Allows --input or -i 
    'output|o=s' => \$output_file, # Allows --output or -o
    'help|h'     => \$help, # Allows --help or -h
) or die "Usage: $0 --input INPUT_DIR --output OUTPUT_FILE [--help]\n";

# Display help message if requested
if ($help) {
    print <<"END_HELP";

Description:
The script reads coding DNA sequences from multi-FASTA files and counts the occurrences of all 64 possible codons by iterating through the sequences in frames of three nucleotides. The total counts for each codon are then normalized by dividing by the total number of codons in each genome, resulting in codon frequency values. The script outputs a tab-delimited file where each row corresponds to a codon and each column represents the codon frequencies for a particular genome.

Author:
Microbial Evogenomics Lab (MiEL), University of Zurich, Department of plant and microbial biology, 2024.

Options:

--input, -i 	INPUT_DIR	Directory containing input FASTA files
--output, -o	OUTPUT_FILE	Output file for codon frequency results
--help, -h			Display this help message

Usage:
perl $0 --input INPUT_DIR --output OUTPUT_FILE 

END_HELP
    exit;
}


# Check if input directory and output file are provided
die "Usage: $0 --input INPUT_DIR --output OUTPUT_FILE\n" unless $input_dir && $output_file;

# Process each FASTA file in the input directory
opendir my $dir, $input_dir or die "Cannot open directory: $!";
my @files = grep { /\.fasta$/ || /\.fa$/ || /\.fna$/ } sort readdir($dir);
closedir $dir;

# Check if any FASTA files are found
if (scalar @files == 0) {
    die "No FASTA files found in the input directory: $input_dir\n";
}

# Initialize storage for codon counts and total codons
my %genome_codon_counts;
my %genome_total_codons;
my @genome_names;

foreach my $file (@files) {
    my $file_path = "$input_dir/$file";
    my $seq_in = Bio::SeqIO->new(-file => $file_path, -format => 'fasta');

    # Initialize codon counts for the current genome
    my %codon_counts = map { $_ => 0 } generate_codons();
    my $total_codons = 0;

    while (my $seq = $seq_in->next_seq) {
        my $sequence = $seq->seq;
        my %current_counts = calculate_codon_counts($sequence);

        foreach my $codon (keys %current_counts) {
            $codon_counts{$codon} += $current_counts{$codon};
        }

        $total_codons += sum(values %current_counts);
    }

    # Store codon counts and total codons for the current genome
    my $genome_name = basename($file, qw(.fasta .fa .fna));
    $genome_codon_counts{$genome_name} = \%codon_counts;
    $genome_total_codons{$genome_name} = $total_codons;
    push @genome_names, $genome_name;
}

# Open output file for writing
open my $out_fh, '>', $output_file or die "Could not open output file '$output_file': $!";

# Print header
print $out_fh "Codon";
foreach my $genome_name (@genome_names) {
    print $out_fh "\t$genome_name";
}
print $out_fh "\n";

# Print codon frequencies for each genome
foreach my $codon (sort keys %{ $genome_codon_counts{$genome_names[0]} }) {
    print $out_fh "$codon";
    foreach my $genome_name (@genome_names) {
        my $count = $genome_codon_counts{$genome_name}{$codon};
        my $total = $genome_total_codons{$genome_name};
        my $frequency = $total ? $count / $total : 0;
        print $out_fh "\t$frequency";
    }
    print $out_fh "\n";
}

close $out_fh;

# Subroutine to calculate codon counts
sub calculate_codon_counts {
    my ($sequence) = @_;
    my %codon_counts = map { $_ => 0 } generate_codons();

    for (my $i = 0; $i < length($sequence) - 2; $i += 3) {
        my $codon = substr($sequence, $i, 3);
        $codon_counts{$codon}++ if exists $codon_counts{$codon};
    }

    return %codon_counts;
}

# Subroutine to generate all possible codons
sub generate_codons {
    my @nucleotides = qw(A C G T);
    my @codons;

    foreach my $n1 (@nucleotides) {
        foreach my $n2 (@nucleotides) {
            foreach my $n3 (@nucleotides) {
                push @codons, "$n1$n2$n3";
            }
        }
    }

    return @codons;
}
