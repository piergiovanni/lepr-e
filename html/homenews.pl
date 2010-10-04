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
my $cgis = sess->new;
my $ajax = CGI::Ajax->new( 'rn' => \&regn, 'edn' => \&ednews, 'vrn' => \&vregn, 'ln' => \&linws, 'mfpg' => \&vewfpg, 'fpg' => \&cofpg, 'fpg2' => \&cofpg2,  'gis' => \&getids, 'dlnw' => \&remnws, 'fdrp' => \&findtxt, 'serc' => \&findrep, 'ucrd' => \&viecard, 'acti' => \&inacti, 'iact' => \&regact, 'son' => \&vyon, 'vcom' => \&gethcom, 'insco' => \&upcom, 'infol' => \&regfol, 'mesg' => \&viewmsg, 'upw' => \&acceptf, flws => \&myfol, edp => \&editp, updp => \&updpr, delit =>\&delactiv, 'inlik' => \&setlike, 'chp' =>\&chpass, 'ckpass' => \&chpassed, 'inl' => \&vtxlk, 'ckse' => \&sendto, 'wrm' => \&writem);
#$ajax->JSDEBUG(1);
#$ajax->DEBUG(1);
my $ref = $ENV{'HTTP_REFERER'};
my $qpar = $ENV{'QUERY_STRING'};
my ($sed, $pippo, $username) =  undef;


if ($qpar eq "esci") {
	$sed = $cgis->crts("logout", "logout", $hq);
	print $hq->redirect( -uri => '/tellyou/login.pl');
}

if ($ref =~ /login/) {
	$sed = $cgis->crts("load", "load", $hq);
	$username = $sed->param('Username');
	$ajax->skip_header(1);
	print $sed->header(-charset=>'UTF-8' );
	$pippo = "qui";
	print $ajax->build_html( $hq, \&main, {-charset=>'UTF-8' });
} else {
	$sed = $cgis->crts("reload", "reload", $hq);
	if ($sed->is_empty) {
		#print "Location: /tellyou/login.pl\n\n";
		#print $hq->redirect( -uri => '/tellyou/login.pl' );
		print $sed->header(-location=>'/tellyou/login.pl', -status=>'302', -charset=>'UTF-8');
	} else {
		$ajax->skip_header(1);
		$username = $sed->param('Username');
		print $sed->header(-charset=>'UTF-8' );
		$pippo = "qua";
		print $ajax->build_html( $hq, \&main );
	}
}




sub main {

	my $vuser = $sed->param('Username');
	#$vuser .= $ref . $pippo ;
	#$vuser .= $sed->id() . $sed->is_expired() . $sed->is_empty;
	my $HTML = $hq->start_html(-script => {-src=> "/tds/js/elabor.js"}, 
				   -style => {-src=> "/tds/css/style_tds.css"},
				   -head=>[$hq->meta({ -http_equiv => "cache-control", -content => "no-cache"}),
                                		$hq->meta({ -http_equiv => "pragma", , -content => "no-cache"}),
                                		$hq->meta({ -http_equiv => "expires", , -content => "-1"})]);
        $HTML .= $ht->homen($vuser);
	$HTML .=<<HT;
HT
	$HTML .= $hq->end_html;
        return $HTML;

}

sub vregn {

	#my ( $username ) = @_;
	return $ht->regne($username);

}

sub ednews {

        my ( $inas ) = @_;
        return $ht->editne($username, $inas);

}

sub vyon {

	my ( $funcajax ) = @_;
	return $ht->hyon( $funcajax );

}

sub regn {

	my ( $loca, $hd01, $title, $link, $hd02, $med, $news, $auth, $timdat, $uinas, $stat ) = @_;
	my $resp = $unw->regnws( $username, $loca, $hd01, $title, $link, $hd02, $med, $news, $auth, $timdat, $uinas, $stat );
	if ($stat eq "update") {
		$resp = $ht->editne($username, $uinas);
	} else {
		my $raf = $unw->lnews( $username );
		$resp = $ht->hlnews($raf, $username);
	}
	return $resp;

}

sub remnws {

        my ( $inas) = @_;
        my $resdel = $unw->delnews($username, $inas);
        my $raf = $unw->lnews( $username );
        $resdel = $ht->hlnews($raf, $username);
        return $resdel;

}


sub delactiv {

        my ( $inas, $fo) = @_;
	my (%itm, $resdel);
	if ($fo) {
		%itm = (table => "activity", items => "idnas = \'$inas\'");
        	$resdel = $unw->delitem($username, $fo, %itm);
        	return $ht->activ($username);
	} else {
		%itm = (table => "activity", items => "idnas = \'$inas\'");
                $resdel = $unw->delitem($username, $fo, %itm);
		%itm = (table => "comments", items => "idnas = \'$inas\'");
		$resdel .= $unw->delitem($username, $fo, %itm);
        	return $ht->activ($username);
	}

}


sub linws {

	#my ( $username ) = @_;
	my $raf = $unw->lnews( $username );
	my $resp = $ht->listnws($raf);
        my $resp2 = $ht->mfpage;
	return ( $resp, $resp2 );

}

sub getids {

	#my ( $username ) = @_;
	my ( $idstr, $adstr );
        my $retid = $unw->chanid( $username );
	my @retar = @$retid;
	foreach (@retar) {
		if ($_) {
			$adstr .= $_ . ";";
		}
	}
	$adstr =~ s/^;//;
        $adstr =~ s/;$//;
	foreach (@retar) {
		if ($_) {
			$_ = substr($_, index($_, ","));
			$_ =~ s/^,//;
			$idstr .= $_ . ",";
		}
	}
	if ($idstr) {
		$idstr =~ s/^,//;
                $idstr =~ s/,$//;
	}
	return ( $idstr, $adstr );
	#return $adstr;

}

sub vewfpg {

# mfpg([ 'firstp' ], [ 'firstp' ])

	my ( $ffpg ) = @_;
        return $ht->mfpage;

}

sub cofpg {

	my ( $title, $Center, $Left1, $Left2, $Center2, $Down ) = @_;
	my $cmpfp = $unw->compfpg($username, $title, $Center, $Left1, $Left2, $Center2, $Down);
	return $cmpfp;

}

sub cofpg2 {

        my ( $idnas ) = @_;
        my $cmpfp = $unw->compfpg2($username, $idnas);
        return $cmpfp;

}

sub findtxt {

	my $txtfind = "<input type=\"text\" id=\"txtkey\" value=\"name\"/><span class=\"lbutton mlink\" onclick=\"serc([ 'txtkey' ], [ 'resu' ]);\">Search</span>";
	return $txtfind;



}

sub inacti {

	my ( $usern, $lmt, $ofst, $nxt ) = @_;
	if ( $usern ) { $username = $usern; }
	if ($nxt eq "n" ) {
		$ofst += 5;
	}
	my $resact = $ht->activ($username, $lmt, $ofst, $nxt);
	return ($resact, '');

}

sub regact {
	
	my ( $newsact, $fuser ) = @_;
	my $resact;
	my $tosend = $us->chkto($newsact);
	if ($tosend ne "not" && $tosend ne "xxx") {
		$fuser = $tosend;
	}
	if ($newsact) {
		$resact = $unw->insact( $username, $newsact, $fuser );
		#if ($fuser) {
		#	$resact = $ht->activ($fuser, '5', '0', 'fol');
		#} else {
			$resact = $ht->activ($username);
		#}
	} else { 
		$resact = $ht->activ($username);
	}
	return $resact;

}

sub regfol {

	my ( $usfol ) = @_;
	my $resfol = $unw->usfollow( $username, $usfol );
	my $reshb = "<b>.....</b>";
	return $reshb;

}

sub findrep {

	my ( $userkeyw ) = @_;
	my $usearch = $unw->finduser( $userkeyw );
        return $usearch;

}

sub viewmsg {


	my ( $modal, $inas) = @_;
	my $getlist = $ht->vmess($username, $modal, $inas);
	return ($getlist);


}

sub viecard {

        my ( $usern ) = @_;
	my $userlog = $sed->param('Username');
	my $vucard = undef;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
	my $gwaitsq = $us->fwait( $userlog, $usern );
	my $gwaitgq = $dbc->sqlstate($dbpg, $gwaitsq , "f");
	if ($gwaitgq) {
		$vucard = $ht->ucard($usern, "a");
	} else {
        	$vucard = $ht->ucard($usern, "1");
	}
	$dbc->dbx($dbpg);
	
        return "$vucard";

}

sub myfol {

	#my ( $username ) = @_;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
	my $folsq = $us->myfollow($username);
	my $folsr = $dbc->sqlstate($dbpg, $folsq, "far");
	my @listf = @$folsr;
	my $y = 0;
	my $lsthtml = "<div><input type=\"hidden\" id=\"fdlmt\" value=\"5\"/><input type=\"hidden\" id=\"fofst\" value=\"0\"/><input type=\"hidden\" id=\"fnext\" value=\"fol\"/>";
	foreach (@listf) {
		$y += 1;
		my $photop = $unw->getufil($_, 'profile', 'a');
		$lsthtml .= "<input type=\"hidden\" id=\"fuser$y\" value=\"$_\"/>";
		$lsthtml .= "<span style=\"width:150px; margin-left:10px;\" onclick=\"acti([ \'fuser$y\',\'fdlmt\',\'fofst\',\'fnext\' ], [ \'resu\' ]);\">$photop</span>";
	}
	$lsthtml .= "</div>";
	$dbc->dbx($dbpg);
	return ($lsthtml);

}

sub gethcom {

        my ( $inas, $rcom ) = @_;
        my $HTML = $ht->icom($username, $inas, $rcom);
        return $HTML;

}

sub acceptf {

	my ( $usfoll, $upw ) = @_;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
	my $upwsq = $us->ufollow($username, $usfoll, $upw);
	my $upwgq = $dbc->sqlstate($dbpg, $upwsq, "update");
	$dbc->dbx($dbpg);
	return $upwgq;

}

sub upcom {

        my ( $title, $chcom, $inas, $rcom) = @_;
        my $rescom = $unw->upcoms( $username, $title, $chcom, $inas);
	$rescom = $ht->icom($username, $inas, $rcom);
        return $rescom;


}

sub editp {

	#my ( $username ) = @_;
	my $resht = $ht->regu($username);
	return $resht;

}

sub updpr {
	
	my ( $name, $surname, $gender, $birthday, $location, $nazionality, $email, $alias, $note ) = @_;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
	my $uppsq = $us->edupd($username, $name, $surname, $gender, $birthday, $location, $nazionality, $email, $alias, $note );
	my %uplq = %$uppsq;
	my $upprq;
	if ($uplq{sql1}) {
		$upprq = $dbc->sqlstate($dbpg, $uplq{sql1}, "update");
	}
	if ($uplq{sql2}) {
		$upprq = $dbc->sqlstate($dbpg, $uplq{sql2}, "update");
	}
	my $resht = $ht->regu($username);
        return $resht;
}

sub setlike {


        my ( $inas, $table) = @_;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $rescom = $unw->setlik( $username, $inas, $table);
	my $liksq = $us->vlik($username, $inas, $table );
        my $liksg = $dbc->sqlstate($dbpg, $liksq, "f");
        return $liksg;

}


sub chpass {

	#my ( $username ) = @_;
	my $html = $ht->chpw();
	return ($html);

}

sub chpassed {

        my ( $password, $npx, $npy ) = @_;
        my $html = $us->chpwd( $username, $password, $npx, $npy);
        return ($html);

}

sub vtxlk {

	my $html =<<HB;
	<input type="text" id="txlk" size="48"/>
HB
	return $html;
}

sub sendto {

	my ( $tos ) = @_;
	my $res = $us->chkto($tos);
	my $res1 = "set";
	if ($res =~ /not/) {
		$res1 = "noset";
		$res = "User not Found";
	} elsif ($res =~ /xxx/) {
		$res = undef;
	} else {
		$res = "write to $res";
	}
	return ($res, $res1);
}

sub writem {

	my ( $mbody ) = @_;
	if ($mbody) {
		my $res1 = $unw->wrmsg($username, '', '', $mbody);
		return ('message send ...', '');
	} else {
		return ('insert destinatary and message .....', '');
	}

}
