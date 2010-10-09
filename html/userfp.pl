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


use lib '../';

use config::settings;
use session::conndb;
use session::sess;
use users::user;
use news::rnews;
use htmlpl::genhtml;


my $hq = CGI->new;
my $ht = genhtml->new;
my $us = user->new;
my $unw = rnews->new;
my $dbc = conndb->new;
my $cgis = sess->new;
my $ajax = CGI::Ajax->new('alns' => \&allnews, 'vie' => \&vnes, 'vcom' => \&gethcom, 'insco' => \&upcom, 'inlik' => \&setlike, 'acti' => \&inacti );
my $ref = $ENV{'HTTP_REFERER'};
my $qpar = $ENV{'QUERY_STRING'};
my @lqpar = split(/\?/,$qpar);
my ($sed, $vuser, $idact, $sqlg, $sqlr, $resp) = undef;
my $pippo = undef;

my $dbreq = $dbc->dbuse();
if ($lqpar[0]) {
	$vuser = $lqpar[0];
	$idact = $lqpar[1];
} else {
       	$vuser = $qpar;
}
if ($lqpar[1] ne "acti") {
	$sqlr = $us->acted($vuser, $idact);
	$sqlg = $dbc->sqlstate($dbreq, $sqlr, "f");
}
if ($sqlg) {
	$sqlr = $us->acted($vuser, $idact, "reqact");
	$sqlg = $dbc->sqlstate($dbreq, $sqlr, "update");
	$resp = "<b>Your account is now enable .......</b>";
	
} 
#else {
#	$resp = "<b>Registration not valid ......</b>";
#}


print $ajax->build_html( $hq, \&main, {-charset=>'UTF-8' } );

sub main {

        #$vuser .= $ref . $pippo ;
        #$vuser .= $sed->id() . $sed->is_expired() . $sed->is_empty;
        #my $HTML = $hq->start_html(-script => {-src=> "/tds/js/elabor.js"},
        #                           -style => {-src=> "/tds/css/style_tds.css"},
        my $HTML = $hq->start_html(     -title   => 'lepr-e',
					-style => {-src=> "/tds/css/style_tds.css"},
					-head=>[$hq->meta({ -http_equiv => "cache-control", -content => "no-cache"}),
                                	$hq->meta({ -http_equiv => "pragma", , -content => "no-cache"}),
                                	$hq->meta({ -http_equiv => "expires", , -content => "-1"})]);

        #$HTML .= $ht->ufpage($vuser);
	if ($resp && $lqpar[1]) {
		$HTML .= $resp;
	} elsif ($lqpar[1] eq 'acti') {
		my $photop = $unw->getufil($vuser, 'profile');
		my $vucard = $ht->ucard($vuser, 'v', 'ppro');
		$HTML .= <<HB;
		<div style="margin-left:140px; margin-right:140px; margin-top:30px;">$photop $vucard</div>
		<div style="margin-left:140px; margin-right:140px; margin-top:50px; border-color: #E6FFC2; border-width: 1px; border-style:solid; >
		<input type="hidden" id="username" value="$vuser"/>
HB
		$HTML .= $ht->activ($vuser, undef, undef, 'ext');
		$HTML .= <<HB;
		</div>
HB
	} else {
		$HTML .= $ht->listans($vuser);
	}
        $HTML .= $hq->end_html;
        return $HTML;

}



sub allnews {

	my ( $username ) = @_;
	my $HTML = $ht->listans($username);
	return $HTML;

}

sub vnes {

	my ( $username, $inas) = @_;
        my $HTML = $ht->viewnws($username, $inas);
	return $HTML;

}

sub gethcom {

	my ( $username, $inas, $rcom ) = @_;
	$rcom = 'hcom';
        my $HTML = $ht->icom($username, $inas, $rcom);
	return $HTML;

}

sub upcom {

	my ( $username, $title, $chcom, $inas, $rcom) = @_;
	$rcom = 'hcom';
	my $rescom = $unw->upcoms( $username, $title, $chcom, $inas);
	$rescom = $ht->icom($username, $inas, $rcom);
	return $rescom;


}



sub setlike {


	my ( $username, $inas, $table) = @_;
        my $dbpg = $dbc->dbuse();
	my $rescom = $unw->setlik( $username, $inas, $table);
	my $liksq = $us->vlik($username, $inas, $table );
        my $liksg = $dbc->sqlstate($dbpg, $liksq, "f");
        return $liksg;

}


sub inacti {

        my ( $username, $lmt, $ofst, $nxt ) = @_;
        if ($nxt eq "n" ) {
                $ofst += 5;
        }
        my $resact = $ht->activ($username, $lmt, $ofst, $nxt);
        return ($resact);

}
