#!/usr/bin/env perl

use strict;
use utf8;
use Env;
use warnings;

my $validationdomain = $ENV{CERTBOT_DOMAIN};
if (not $validationdomain) {
  die "ERROR: No domain string found!";
}
my $zonefiledirpath = $ENV{zoneprefix};
if (not $zonefiledirpath || -d $zonefiledirpath) {
  die "ERROR: No zone files prefix provided or is not a directory!";
}
my $zonefilepath = $zonefiledirpath + $validationdomain + ".zone";
if (not -f $zonefilepath || -z $zonefilepath) {
  die "ERROR: Zone file not found or empty!";
}

open(ZONEFILE, "< :encoding(UTF-8)", $zonefilepath);
while (my $line = <ZONEFILE>) {
  print $line . "\n";
}
close(ZONEFILE);
