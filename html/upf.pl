#!/usr/bin/perl -w
# Copyright (C) 2010 Piergiovanni Gualotto
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details or 
# see the COPYRIGHT agpl-3.0.txt file.
#

use strict;
use CGI;
use CGI::Ajax;
use CGI::Session;

use lib '../';
use news::rnews;

my $hq = CGI->new;
my $unw = rnews->new;

my $qpars = $ENV{'QUERY_STRING'};
my @lpars = split(/&/, $qpars);
my $upfile = $hq->param("file");

&upfile($upfile);
&getfile();


sub upfile {

my ( $file ) = @_;
my $res = $unw->uploadf($lpars[0], $file, $lpars[1], $lpars[2]);
print $hq->header();
print "$res ";
return $res;


}

sub getfile {

my ( $username, $imgtype ) = @_;
my $res = $unw->getufil($lpars[0], $lpars[1], '', $lpars[2]);
print "$res ";
return $res;

}


