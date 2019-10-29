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

my $validationdomain = $ENV{CERTBOT_DOMAIN};
if (not $validationdomain) {
  die "ERROR: No domain string found!";
}
if ($ENV{zoneprefix}) {
  $zonefiledirpath = $ENV{zoneprefix};
}
if (not $zonefiledirpath || -d $zonefiledirpath) {
  die "ERROR: No zone files prefix provided or $zonefiledirpath is not a directory!";
}
my $zonefilepath = $zonefiledirpath . "/" . $validationdomain . ".zone";
if (not -f $zonefilepath || -z $zonefilepath) {
  die "ERROR: Zone file $zonefilepath not found or empty!";
}

my @newzonefilecontent;
my $oldzonefilepath = $zonefilepath . "-" . time;

open(ZONEFILE, "< :encoding(UTF-8)", $zonefilepath);
while (my $line = <ZONEFILE>) {
  if ($line =~ /^_acme-challenge/) {
    print "cleaning $line";
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

if (-e $zonefilepath) {
  die "ERROR: We still see our old zonefile path!";
}

# create a new zone file
open(ZONEFILE, "> :encoding(UTF-8)", $zonefilepath);
foreach my $nline (@newzonefilecontent) {
  print ZONEFILE $nline;
}
close(ZONEFILE);


