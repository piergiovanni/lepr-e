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
use DBI;
use DBD::Pg;

package config::settings;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub dbparams { 
	
	my $self = 'shift';
	my $user = 'postgres';
	my $pwd = 'postgres';
	my $dbname = 'tellyou';
	my $host = 'localhost';
	my $port = '5432';
	
	return ($user, $pwd, $dbname, $host, $port);

}

sub smtp_par {

        my $self = 'shift';
	my $fromsend = 'piergiovani@gmail.com';
        my $user = 'postgres';
        my $pwd = 'postgres';
        my $host = 'localhost';
        my $port = '25';

        return ($fromsend, $user, $pwd, $host, $port);

}


sub parmsetup {
	
	my $self = 'shift';
	my (%psetup) = ( 'dirsetup' => '/home/pgualotto/thinkdoshare', 
			'domain' => 'http://localhost/tellyou/');
	return (%psetup);
	
}

1;
