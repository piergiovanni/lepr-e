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

use lib '../';

use config::settings;



package conndb;

sub new {
    my $class = shift;
    return bless {}, $class;
}


sub dbuse {

	my $self = shift;
	my ( $user , $pwd , $dbname , $host , $port ) = config::settings::dbparams;
	#my $conn = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;port=$port;options=$options",
	my $conn = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;port=$port",
                      $user,
                      $pwd
        #              {AutoCommit => 0, RaiseError => 1, PrintError => 0}
                     );
	return ($self, $conn);

}
sub dbx {

	my $self = shift;
	my ( $dbh ) = @_;
	$dbh->disconnect();
	return ($self);

}

sub sqlstate {
	
	my $self = shift;
	my ($enres, $result, @res) = undef;
	my @mulrow;
	my ( $dbh, $sql, $oper) = @_;
	my $sqlr = $dbh->prepare($sql);
	$sqlr->execute();
	if ( $oper eq "f" ) {
		$result = $sqlr->fetchrow();
		if ($result) {
			return ($self, $result);
		} else {
			return ($self, undef);
		}
	} else {
		if ( $oper eq "far" ) {
				while (@mulrow = $sqlr->fetchrow_array) {
					foreach ( @mulrow ) {
						push(@res, $_);
					}
				}	
			return ($self, \@res);
		}
	return ($self, $result);
	}
}
	
#my $dbpg = conndb->dbuse();
#my $pippo = conndb->sqlstate($dbpg, 'select * from session;', "far");
#conndb->dbx($dbpg);
#my @tt = @$pippo;
#foreach (@tt) {

#	print $_;

#}
	
1;
