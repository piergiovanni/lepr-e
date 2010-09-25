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


use lib '../';

use config::settings;
use session::conndb;
use users::user;
use htmlpl::genhtml;

my $hq = CGI->new;
my $sessl = CGI::Session->load($hq);
my $ht = genhtml->new;
my $dbc = conndb->new;
my $us = user->new;
my $unews = rnews->new;
my %psetup = config::settings::parmsetup;
my $dst = $psetup{'dirsetup'};
my ($text, $imgsrc, $dir, $md5text, $lreg, $reg, $fimg);
if (!$hq->param("imgv")){
	$fimg = $dst . "\/web\/img\/" . $hq->param("ddel") . "\.gif";
        unlink($fimg);
	($text, $imgsrc, $dir) = $unews->regver();
	$md5text = $us->pwdmd5('', $text);
	$text = $md5text;
}
my $ajax = CGI::Ajax->new( 'regus' => \&ru, 'activ' => \&ac);
#$ajax->skip_header(1);
my $qpar = $ENV{'QUERY_STRING'};
my @lqpar = split(/\?/,$qpar);
my $ipaddress = $ENV{'REMOTE_ADDR'};

if ($hq->param("name") || $hq->param("surname") || $hq->param("email") || $hq->param("username") || $hq->param("pwd")) {
	
	$reg = &ru($hq->param("name"), $hq->param("surname"), $hq->param("email"), $hq->param("username"), $hq->param("pwd"), $ipaddress);
	if ($reg =~ /xx/ ) {
		$lreg ="<div style=\"font-size : large; margin-top:50px;\"><b>Check your email and activate your Account !!!</b></div>";
		print $ajax->build_html( $hq, \&main , {-charset=>'UTF-8' });
		#print $sessl->header(-location=>'/tellyou/login.pl', -status=>'302', -charset=>'utf-8');
	} else {
		$lreg = $reg;
		print $ajax->build_html( $hq, \&main , {-charset=>'UTF-8' });
	}
} elsif ($lqpar[1] =~ /0_/ && $hq->param("imgv")) {
	$fimg = $dst . "\/web\/img\/" . $hq->param("ddel") . "\.gif";
        unlink($fimg);
        $md5text = $us->pwdmd5('', $hq->param("imgv"));
	$reg = &ac($lqpar[0], $lqpar[1], "reqact", $md5text, $hq->param("bok"));
	if ($reg =~ /xx/) {
		print $sessl->header(-location=>'/tellyou/login.pl', -status=>'302', -charset=>'utf-8');
	} else {
                $lreg = $reg;
		print $sessl->header(-location=>"/tellyou/regu.pl?$lqpar[0]?$lqpar[1]?ee", -status=>'302', -charset=>'utf-8');
                #print $ajax->build_html( $hq, \&main , {-charset=>'UTF-8' });
        } 
} else {
	$reg = 'no' . $hq->param("name") . $hq->param("surname") . $hq->param("email") . $hq->param("username") . $hq->param("pwd");
	print $ajax->build_html( $hq, \&main , {-charset=>'UTF-8' });
}
	

sub main {
	
	my $HTML = $hq->start_html(-style => {-src=> "/tds/css/style_tds.css"},
                                   -head=>[$hq->meta({ -http_equiv => "cache-control", -content => "no-cache"}),
                                                $hq->meta({ -http_equiv => "pragma", , -content => "no-cache"}),
                                                $hq->meta({ -http_equiv => "expires", , -content => "-1"})]);
	$HTML .= $hq->startform();
	if ($lqpar[2]) { $lreg = "Error activate user";}
	if ($lqpar[1] =~ /0_/) {
		$HTML .= $ht->reguf($text, $imgsrc, $dir);
	} else {
		$HTML .= $ht->reguf();
	}
	$HTML .=<<HT; 
	<INPUT type="hidden" id='ipadd' value=$ipaddress>
HT
	$HTML .= $hq->endform;
	$HTML .= "<a style=\"font-size : large;\">$lreg</a>";
	$HTML .= $hq->end_html;
	return $HTML;

}


#*********************************
#	<div id="ok" onclick="regus([ 'name', 'surname', 'Username', 'birth', 'email', 'alias', 'gender', 'location', 'country', 'note', 'password', 'ipadd', 'sess' ], [ 'resu' ]);" ><img src="/tds/img/ok.png"  width="32" height="32" /></div>
#*********************************


sub ru {

	my ( $name, $surname, $email, $username, $password, $ipaddress, $var1, $var2, $stot, $birthday, $alias, $gender, $location, $country, $note, $session ) = @_;
	my $res = $us->reguser($name, $surname, $email, $username, $password, $ipaddress, $var1, $var2, $stot, $birthday, $alias, $gender, $location, $country, $note, $session);
	return $res;

}

sub ac {

	my ( $username, $idact, $ckt, $bok, $text) = @_;
	my $res;
	my $dbreq = $dbc->dbuse();
	my $sqlr = $us->acted($username, $idact, $ckt, $bok, $text);
	my $sqlg = $dbc->sqlstate($dbreq, $sqlr, "update");
	$sqlr = $us->acted($username, $idact, "ckact");
        $sqlg = $dbc->sqlstate($dbreq, $sqlr, "f");
	if ($sqlg == 1) {
		$res = "xx";
	} else {
		$res = "Error activate user !!!!!";
	}
	return $res;
}
