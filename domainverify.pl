#!/usr/bin/env perl

use strict;
use utf8;
use Env;
use warnings;
use File::Basename;

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

open(ZONEFILE, "< :encoding(UTF-8)", $zonefilepath);
while (my $line = <ZONEFILE>) {
  print $line . "\n";
}
close(ZONEFILE);
