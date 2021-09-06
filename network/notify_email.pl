#!/usr/bin/env perl

use strict;
use Getopt::Long;
use Carp;
use warnings;
use Email::Send::SMTP::Gmail;
 
our $VERSION = 0.3;
my $mail;
my ( $sender, $recipient ) = ( '$sender@yahoo.com', '$recipient@mail.provider' );
my ( $passwd ) = ( "PASSWORD" );

my ( $host, $port ) = ( "smtp.mail.yahoo.com", 465);
my ( $verbose, $debug ) = ( 0, 0 );
my ( $subject, $body, $bodyFile ) = ( "", "", undef );
my ( $auth, $timeout ) = ( "LOGIN", 60 );
my ( $layer ) = ( "ssl" );
my ( $version ) = undef;
 
GetOptions(
    "host=s"      => \$host,
    "sender=s"    => \$sender,
    "recipient=s" => \$recipient,
    "passwd=s"    => \$passwd,
    "recipient=s" => \$recipient,
    "subject=s"   => \$subject,
    "body=s"      => \$body,
    "bodyFile=s"  => \$bodyFile,
    "port=i"      => \$port,
    "auth=s"      => \$auth,
    "timeout=i"   => \$timeout,
    "layer=s"     => \$layer,
    "verbose"     => \$verbose,
    "debug"       => \$debug,
    "version"     => \$version,
);
 
if ($version) {
    print "notify_email.pl v$VERSION\n";
    print "Usage: notify_email.pl [--subject SUBJECT] [--body BODY_MESSAGE]\n";
    exit(0);
}
 
if (defined($bodyFile) && $body eq "") {
    my @files = split ",", $bodyFile;
    for my $file ( @files ) {
        if (-e $file) {
            open my $fh, "<", $file or croak "Cannot open $file!";
            while (<$fh>) {
                $body .= $_;
            }
        }
    }
}
 
$mail = Email::Send::SMTP::Gmail->new(
    -smtp => $host,
    -login=> $sender,
    -pass => $passwd,
    -port => $port,
    -auth => $auth,
    -timeout => $timeout,
    -layer => $layer,
    -verbose => $verbose,
    -debug => $debug,
);
 
$mail->send(
    -to => $recipient,
    -subject => $subject,
    -body => $body,
    -verbose => $verbose,
    -debug => $debug,
);
 
$mail->bye;
 
__END__
 
=head1 NAME
 
B<notify_email> sends an email to a specified address.
 
=head1 SYSNOPSIS
 
=over
 
=item *) basic usage
 
    notify_email.pl --subject SUBJECT --body BODY
 
=item *) a head-up when a job is finished
 
    long_running_job.sh 2> err && notify_email.pl --subject "job done on $HOSTNAME at `date`" --bodyFile err
 
=back
 
=cut
