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
use htmlpl::genhtml;
use lang::langua;

my $hq = CGI->new;
my $ht = genhtml->new;
my $us = user->new;
my $cgis = sess->new;
my $leng = langua->new;
my $sed = $cgis->crts("reload", "reload", $hq);
my $ajax = CGI::Ajax->new('login' => \&lg, 'vtxe' => \&txte, 'repw' => \&newpw);
my $nsed = "sgo";
my ($lgproblem, $codmd5) = undef;

if ( $hq->param("Username") || $hq->param("password") ) {
	$nsed = &lg( $hq->param("Username"), $hq->param("password"), $hq);
	$codmd5 = $us->pwdmd5('',$hq->param("Username"));
	if ( $nsed =~ /Error/ ) {
		$lgproblem = $nsed;
		print $ajax->build_html( $hq, \&main, {-charset=>'UTF-8'});
	} else {
		print $nsed->header(-location=>"/tellyou/homenews.pl?", -status=>'302', -charset=>'utf-8'); 
		#print $hq->redirect( -uri => '/tellyou/homenews.pl' ); 
	}
}
if ( $sed->is_empty && $nsed eq "sgo" ) {
	print $ajax->build_html( $hq, \&main, {-charset=>'UTF-8' });
} elsif ($sed->id()) {
	my $ulog = $ht->getloged();
	$codmd5 = $us->pwdmd5('',$ulog);
	print $sed->header(-location=>"/tellyou/homenews.pl", -status=>'302', -charset=>'utf-8'); 
	#print $hq->redirect( -uri => '/tellyou/homenews.pl' ); 
} else {
	$lgproblem = $nsed;
}
		

sub main {

        my $ipaddress = $ENV{'REMOTE_ADDR'};
        #my $HTML = $hq->start_html(-onload=>"login([ 'Username', 'password', 'cgi' ], [ 'resu' ])");
	my $HTML = $hq->start_html(    -head=>[$hq->meta({ -http_equiv => "cache-control", -content => "no-cache"}),
                                        $hq->meta({ -http_equiv => "pragma", , -content => "no-cache"}),
                                        $hq->meta({ -http_equiv => "expires", , -content => "-1"})]);

	#$HTML .= $hq->startform(-onsubmit=>"login([ 'Username', 'password', 'cgi'' ], [ 'resu' ])", -method=>'GET');
        $HTML .= $hq->startform();
	$HTML .= $ht->login($lgproblem);
        $HTML .=<<HT;
        <INPUT type="hidden" id='ipadd' value=$ipaddress>
        <INPUT type="hidden" id='cgi' value=$hq>
HT
	#$HTML .= $lgproblem;
	$HTML .= $hq->endform;
        $HTML .= $hq->end_html;
        return $HTML;

}

sub lg {
	my ( $username, $password, $cgi ) = @_;
	my $sed = $cgis->crts($username, $password, $cgi );
	my $resp = undef;
	if ($sed =~ /Error/) {
		$resp = "<div class=\"tba bg_tb1\" style=\"font-size : large; color : red;\"><br/>$sed</div>";
		return $resp; 
	} else {
		return $sed;
	}
}


sub txte {

	my $htm =<<HB;
<span><b>Email</b></span><span>   <INPUT type="text" name="chema" id="chema"/><INPUT type="button" value="Send" onclick="repw(['chema', 'NO_CACHE'],['ckres', 'chema']);"/></span><div id="ckres"></div>
HB
	return $htm;

}

sub newpw {

	my ($uemail) = @_;
	my $respw = $us->forgotpw('', $uemail);
	if ($respw eq 'xx') {
		$respw = '<b>Email not found</b>';
	} else {
		$respw = "<b>check you email for a new password and to activate account</b>";
	}
	return ($respw, '');;

}
