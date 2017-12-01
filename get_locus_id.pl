use strict;
use warnings;

#need LWP::Simple to use "get" to retrieve page for url
use LWP::Simple;

my $file = $ARGV[0];
my $output = $file;
$output =~ s/.gis.txt//g;
#open output file fetch_test2.txt in working directory
open(OUT, ">$output.locus.txt")|| die "failed to open file: $!\n";

#open input file test.txt
open(FILE, $file) || die "failed to open input file: $!\n";


#foreach id in the file, fetch the protein page in XML and print to output file - do for all id's in the file one at a time
while(<FILE>){
	#chomp gets rid of new line character
	chomp;
	
	#the id in the test.txt FILE is referred to as $_, so we are renaming $_ as $id to make it easier to keep track of
	my $id = $_;
	my $link = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=protein&db=gene&id=$id&retmode=xml";
	my $elinkrecord = get($link);
	my $geneid = "null";
	$elinkrecord =~ s/\n//g;
	if($elinkrecord =~ /<Link>\s*<Id>(\d+)<\/Id>\s*<\/Link>/){
		$geneid = $1; print "found $1\n";	
	}
	
	if ($geneid eq "null"){
		print OUT "$id\tnull\tnull\n";
		next;
	}
	my $fetch = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=gene&id=$geneid&retmode=xml";

	my $record = get($fetch);
	#each fetch will be placed in th record. substituting a new line character for nothing- globally
	$record =~ s/\n//g;
	my $locus = "null";
	if ($record =~ /<Gene-ref_locus-tag>(.+)<\/Gene-ref_locus-tag>/){
		$locus = $1;
	}

	#printing out the gi#, cdd#, start, and end of domains, each separated by a tab
	print OUT "$id\t$geneid\t$locus\n";
	
	
}
close(OUT);
