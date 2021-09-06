#!usr/bin/env perl 

use strict;
use warnings;
use File::Find;
use Encode;
use Getopt::Long;

my ($from, $to, $dirname, $ext) = ('cp936', 'utf8', '.', 'txt');
GetOptions('from|f=s' => \$from,
           'to|t=s'   => \$to,
           'dir|d=s' => \$dirname,
           'extension|e=s' => $ext);

my $INPUT = undef;
my $OUTPUT = undef;

sub eachfile 
{
	my $filename = $_;
#	my $fullpath = $File::Find::name; 
# remember that File::Find changes your CWD, so you can call open with just $_
	if (-e $filename && $filename =~ /\.$ext$/) 
	{
		open $INPUT,"<",$filename;
		open $OUTPUT,">",$filename . "~";
		while (<$INPUT>)
		{
			my $data = encode($to,decode($from,$_));
			print $OUTPUT $data;
		}
		$OUTPUT = undef;
		$INPUT = undef;
		rename($filename . "~", $filename);
	}
}

find (\&eachfile, $dirname);

=head1 SYNOPSIS
recursively convert files from one charset (CP936) to another (UTF-8)
=cut
=head1 USAGE 
perl -f cp936 -t utf8 -d dir -e extension
=cut
