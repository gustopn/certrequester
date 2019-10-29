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

open(ZONEFILE, "< :encoding(UTF-8)", $zonefilepath);
while (my $line = <ZONEFILE>) {
  print $line;
}
close(ZONEFILE);
