#!usr/bin/env perl

use strict;
use warnings;
use File::Find;
use Encode;
use Getopt::Long;
use Carp;

my ( $in, $bak, $content, $title ) = ( undef, '.bak', 'content.opf', undef );
GetOptions(
    'in|i=s' => \$in, 
    'bak|b=s' => \$bak, 
    'content|c=s' => \$content,
    'title|t=s'   => \$title,
) or usage();

sub usage {
    print "edit_epub_title.pl --in|-i infile.epub|indir [--bak|-b '.bak'] [--content|-c content.opf] --title|-t 'infile'\n";
}

sub eachfile {
    my ( $content, $bak, $title ) = @_;
    return sub {
        my $infile = $_;
        my $ttl;
        if (-e $infile && $infile =~ /\.epub$/) {
            if (!defined($title) || $title eq '') {
                $ttl = $infile;
                $ttl =~ s/\.epub$//;
            } else {
                $ttl = $title;
            }
            my $bakfile = $infile . "$bak";
            my $tmpfile = $infile . ".tmp";
            my $unzipped = $infile; 
            $unzipped =~ s/\.epub$//;
            print "\tinfile=$infile, ttl=$ttl, bakfile=$bakfile, tmpfile=$tmpfile, unzipped=$unzipped\n";
            print "\tunzip -o $infile -d $unzipped >/dev/null\n";
            my $ret = system("unzip -o $infile -d $unzipped >/dev/null");
            if ($ret != 0) {
                croak "File unzip failed!";
            }
            my $content_file = $unzipped . '/' . $content;
            my $content_file_new = $content_file . ".0";
            my ( $content_file_h, $content_file_newh );
            open $content_file_h, "<", $content_file or croak "Cannot open $content_file!";
            open $content_file_newh, ">", $content_file_new or croak "Cannot open $content_file_new!";
            while ( <$content_file_h> ) {
                my $line = $_;
                if ($line =~ /<dc:title>.*<\/dc:title>/) {
                    $line =~ s#<dc:title>.*</dc:title>#<dc:title>$ttl</dc:title>#;
                }
                print $content_file_newh $line;
            }
            rename $content_file_new, $content_file or croak "Cannot move $content_file_new to $content_file!";
            print "\t7z a -tzip $tmpfile ./$unzipped/* > /dev/null\n";
            $ret = system("7z a -tzip $tmpfile ./$unzipped/* > /dev/null");
            if ($ret != 0) {
                croak "File compression failed!";
            }
            rename $infile, $bakfile or croak "Cannot move $infile to $bakfile!";
            rename $tmpfile, $infile or croak "Cannot move $tmpfile to $infile!";
            $content_file_h = undef;
            $content_file_newh = undef;
        }
    }
}

sub main {
    print "content=$content, bak=$bak, title=$title, in=$in\n";
    my $func = eachfile($content, $bak, $title);
    if ( -d $in ) {
        find({ wanted => \&{$func}}, $in);
    } elsif ( -f $in ) {
        &{$func}($in);
    } else {
        croak "Input not existing: $in!";
    }
}

if (!defined(caller)) {
    main();
}

=head1 NAME
Modify the title of an .EPUB file or a directory containing .EPUB files
=cut
=head1 SYNOPSIS
perl edit_epub_title.pl --in|-i infile.epub|indir [--bak|-b '.bak'] [--content|-c content.opf] --title|-t 'infile'
=cut
