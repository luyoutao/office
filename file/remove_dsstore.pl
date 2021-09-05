#!/usr/bin/perl

use strict;
use warnings;
use File::Find;
use Getopt::Long;

my @list = ();
my $indir;
my $dry     = 0;
my $help    = 0;
my $version = 0;
our $VERSION = 0.2;

sub usage {
    print STDERR <<DOC;
Summary:
    Walk recursively through directories and remove .DS_Store and ._ files

Usage:
    perl remove_dsstore.pl --indir|-i dir [--dry|-d] [--help|-h] [--version|-v]
DOC
}

GetOptions(
    "indir|i=s" => \$indir,
    "dry|d"     => \$dry,
    "help|h"    => \$help,
    "version|v" => \$version,
) or &usage() && exit(-1);

if ($help) { &usage() && exit(0); }

if ($version) {
    print STDERR "v$VERSION\n";
    exit(0);
}

sub rm_dsstore {
    if ( -f $_ && ( $_ eq '.DS_Store' || $_ =~ /^\\._/ ) ) {
        print "Found $File::Find::name...\n";
        push @list, $File::Find::name;
    }
}

find( \&rm_dsstore, $indir );
for my $l (@list) {
    unless ($dry) {
        print "Removing $l...\n";
        unlink($l) or warn "Cannot remove $l!";
    }
}
