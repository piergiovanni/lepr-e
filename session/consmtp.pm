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
use Encode;
use Net::SMTP;


use lib '../';

use config::settings;



package consmtp;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub c_smtp {

	my $self = shift;
	my ($username, $tosend, $subj, $datam) = @_;
	my ($fromsend, $user, $pwd, $host, $port) = config::settings::smtp_par;
	my $esender = new Net::SMTP(
        	$host,
        	Hello   =>      'lepre',
        	Port    =>      $port);
 	$esender->mail($fromsend);
 	$esender->to($tosend);
	$esender->data;
	$esender->datasend("Subject: $subj\n");
	$esender->datasend("$datam");
	$esender->dataend;
	$esender->quit;
	return ($esender);


}


1;
