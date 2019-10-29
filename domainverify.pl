#!/usr/bin/env perl

use strict;
use utf8;
use Env;
use warnings;
use File::Basename;

# This is a temporary hardcoded quickfix, it should be removed ASAP
my @scriptpath = split(/\//, dirname(__FILE__));
pop @scriptpath;
pop @scriptpath;
push @scriptpath, "work";
push @scriptpath, "zonefiles";
my $zonefiledirpath = join("/", @scriptpath);

my $validationstring = $ENV{CERTBOT_VALIDATION};
my $validationdomain = $ENV{CERTBOT_DOMAIN};

if (not $validationstring) {
  die "ERROR: No validation string found!";
}
if (not $validationdomain) {
  die "ERROR: No domain string found!";
}

if ($ENV{zoneprefix}) {
  $zonefiledirpath = $ENV{zoneprefix}; 
}
if (not $zonefiledirpath || -d $zonefiledirpath) {
  die "ERROR: No zone files prefix provided or is not a directory!";
}

my $zonefilepath = $zonefiledirpath . "/" .  $validationdomain . ".zone";
if (not -f $zonefilepath || -z $zonefilepath) {
  die "ERROR: Zone file $zonefilepath not found or empty!";
}

my @newzonefilecontent;
my $oldzonefilepath = $zonefilepath . "-" . time;

open(ZONEFILE, "< :encoding(UTF-8)", $zonefilepath);
while (my $line = <ZONEFILE>) {
  if ($line =~ /^_acme-challenge/) {
    if (-f $oldzonefilepath) {
      print "WARNING: Recognized a re-run, quitting gracefully\n";
      # TODO: Rewrite this to a break-loop having close only once and then check for a variable of second-run, outputting message.
      close(ZONEFILE);
      exit 0;
    }
    print "WARNING: A $line found, this should NOT happen!\n";
  } else {
    push @newzonefilecontent, $line;
  }
}
close(ZONEFILE);

if (not -e $oldzonefilepath) {
  rename $zonefilepath, $oldzonefilepath;
} else {
  die "ERROR: Could not move old zonefile $zonefilepath away!";
}

# generate DNS TXT verification string
my $dnsverifytxt = "_acme-challenge  60 IN TXT " . $validationstring . "\n";
print "$dnsverifytxt \ngenerated and will be appended to the end of new zone file\n";

if (-e $zonefilepath) {
  die "ERROR: We still see our old zonefile path!";
}

# create a new zone file
open(ZONEFILE, "> :encoding(UTF-8)", $zonefilepath);
foreach my $nline (@newzonefilecontent) {
  print ZONEFILE $nline;
}
print ZONEFILE $dnsverifytxt;
close(ZONEFILE);

# just get it over with
@scriptpath = split(/\//, dirname(__FILE__));
pop @scriptpath;
push @scriptpath, "autodnssec";
push @scriptpath, "resign_dnssec.sh";
my $updatescript = join("/", @scriptpath);
if (-x $updatescript && -f $updatescript) {
  system($updatescript, "-u")
}
