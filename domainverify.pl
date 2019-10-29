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
open(ZONEFILE, "< :encoding(UTF-8)", $zonefilepath);
while (my $line = <ZONEFILE>) {
  if ($line =~ /^_acme-challenge/) {
    print "WARNING: A $line found, this should NOT happen!";
  } else {
    push @newzonefilecontent, $line;
  }
}
close(ZONEFILE);

my $oldzonefilepath = $zonefilepath . "-" . time;
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

