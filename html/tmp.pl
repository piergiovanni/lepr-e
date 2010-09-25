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
use CGI::Session;
use CGI::Ajax;
use MIME::Base64 qw(encode_base64);

use lib '../';

use config::settings;
use session::conndb;
use users::user;
use htmlpl::genhtml;



my $buf = '';
my $fsize = -s  '/tmp/apple-logo1.jpg';
open(FILE, "/tmp/apple-logo1.jpg") or die "$!";
read(FILE, $buf, $fsize);
my $fbase64 = encode_base64($buf);
print $fbase64;
my $dbc = conndb->new;
my $dbpg = $dbc->dbuse();
my $insql = "insert into upfiles (imgname, imgfile, username) values ('apple-logo1.jpg', \'$fbase64\', 'piergiovanni');";
my $resql = $dbc->sqlstate($dbpg, $insql, "insert");

