#!/usr/bin/perl

use strict;
use warnings;
use FASTAmodule2;
use Data::Dumper;

my $file = shift @ARGV;
#$file is 'FASTA.txt'

open (IN, '<', $file) || die "can't open $file:$!\n";

my @name;
my @sequence;
my $array_length= -1;

while (my $lines = <IN>){
	chomp $lines;
	if ($lines =~ /^>/){
		$array_length++;
		$name[$array_length] = $lines;
		$sequence[$array_length]='';
	}
	else{
		$sequence[$array_length] .= $lines;
	}	
}

close IN;

my %hash;
my $num_genes = scalar @name;	
for (my $i = 0; $i < $num_genes; $i++){
	$hash{$name[$i]} = $sequence[$i];
}

my $geneName;
my $description;
my $seq;
my $seq_length;
my %big_hash;

foreach my $header (sort keys %hash){
	$geneName = get_name ($header);
	$description = get_description ($header);
	$seq_length = length ($hash{$header});
	$seq = $hash{$header};
	$big_hash{$geneName}{'length'} = $seq_length;
	$big_hash{$geneName}{'description'} = $description;
	$big_hash{$geneName}{'sequence'} = $seq;
	my @nucleotides = split ('', $seq);
	foreach my $n (@nucleotides){
		$big_hash{$geneName}{'nuc_count'}{$n}++;
	}
	$big_hash{$geneName}{'GCcontent'} = ($big_hash{$geneName}{'nuc_count'}{G} + $big_hash{$geneName}{'nuc_count'}{C}) / $seq_length; 	
}

#print Dumper \%big_hash;

open (OUT, '>', 'all.txt') || die "can't open output file:$!\n";

print OUT join ("\t", 'Gene', 'Description', 'GCcontent', 'A', 'C', 'T', 'G','Length', 'Sequence'), "\n";

foreach my $name_id (sort keys %big_hash){
	print OUT join ("\t", $name_id,
		$big_hash{$name_id}{'description'},
		$big_hash{$name_id}{'GCcontent'},
		$big_hash{$name_id}{'nuc_count'}{A},
		$big_hash{$name_id}{'nuc_count'}{C},
		$big_hash{$name_id}{'nuc_count'}{T},
		$big_hash{$name_id}{'nuc_count'}{G},
		$big_hash{$name_id}{'length'},
		$big_hash{$name_id}{'sequence'},
		), "\n";		
}


close OUT;






__END__

my %h_name_seq;
my %h_name_desc;

#keys are the headers and values are the sequences


my $name;
my $description;
my $seq_count;
while (my $lines = <IN>){
	chomp $lines;
	if ($lines=~ /^>/){	
		my $header = $lines =~ /(^>\S+)(.+)?/;
		$name = $1;
		$description = $2;
		$h_name_desc{$name} = $description; #key = gene name; value = description.
		#print "$description\n";
	}
	else{
		$h_name_seq{$name} .= $lines; #key = gene name; value = sequence with \n removed so seq is string.
	}	
}

my $num_seq = keys %h_name_seq;
