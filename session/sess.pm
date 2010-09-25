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
use CGI::Session;


use lib '../';

use config::settings;
use session::conndb;
use users::user;

package sess;

sub new {
    my $class = shift;
    return bless {}, $class;
}

#       my $sdb = CGI::Session->load('driver:PostgreSQL', $cgi,
#    {
#        TableName=>'cgisess',
#        IdColName=>'idsession',
#        DataColName=>'session',
#        Handle=>$dbpg,
#    });

#               $sdb =  new CGI::Session('driver:PostgreSQL', $cgi,
#       {
#               TableName=>'cgisess',
#               IdColName=>'idsession',
#               DataColName=>'session',
#               Handle=>$dbpg,
#         });


sub crts {
	
	my $self = shift;
	my ( $username, $password, $cgi) = @_;
	my $sid = undef;
	my $sdb = undef;
	my $userv = undef;
	my $ret = undef;
	my $pus = user->new();
	my $dbc = conndb->new();
	my $dbpg = $dbc->dbuse();
	my $ausc = $pus->auser($username);
	my @aus = $dbc->sqlstate($dbpg, $ausc, "f");
	my $pusc = $pus->puser($username, $password);
        my @pusi = $dbc->sqlstate($dbpg, $pusc, "f");
	my $ckena = $pus->acted($username, "1", "ckact");
	my $ckenq = $dbc->sqlstate($dbpg, $ckena, "f");
	if ($username eq "logout" && $password eq "logout" ) {
		my $sdb = CGI::Session->load($cgi);
		$sdb->delete();
		$sdb->flush();
		$dbc->dbx($dbpg);
                return ( $self, $sdb );
	}
	if ($username eq "reload" && $password eq "reload" ) {
                my $sdb = CGI::Session->load($cgi);
                $username = $sdb->param('Username');
                $password = $sdb->param('password');
                $dbc->dbx($dbpg);
                return ( $self, $sdb );
        }
	if ($username eq "load" && $password eq "load" ) {
		my $sdb = CGI::Session->load();
		$username = $sdb->param('Username');
		$password = $sdb->param('password');
		$dbc->dbx($dbpg);
		return ( $self, $sdb );
	} else {
	#	if ($sdb->is_expired || $aus[1]) {
        	if ($pusi[1] && $aus[1] && $ckenq) {
			$sdb =  new CGI::Session();
			$sdb->param('Username', $username);
			$sdb->param('password', $password);
			$dbc->dbx($dbpg);
        	} else {
			if (!$pusi[1]) { $ret = " Password Invalid -"; }
			if (!$aus[1] || !$ckenq) { $ret .= " Username Invalid"; }
			#if (!$ckenq) { $ret .= " Account is disabled";}
			$sdb = "Error $ret";
			$dbc->dbx($dbpg);
        	}
	return ( $self, $sdb );
	}

}

1;
