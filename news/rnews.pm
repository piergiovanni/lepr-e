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
use IO::File;
use MIME::Base64;
use Image::Magick;
use String::Random;

use lib '../';

use config::settings;
use session::conndb;
use users::user;
use htmlpl::genhtml;


package rnews; 

sub new {
    my $class = shift;
    return bless {}, $class;
}


sub idcone {

	my $self = shift;
	my $idnas = `date "+%N"`;
	my $ra = rand(9999);
	$idnas =~ s/^\s+//;
	$idnas =~ s/\s+$//;
	$idnas .= $ra;
	return ($self, $idnas);

}

sub regmat {

	my $self = shift;
	my ($var1, $var2, $tvar) = @_;
	if ($var1 || $var2 || $tvar) {
		my $stot = $var1+$var2;
		if ($tvar == $stot) {
			return ($self, "ok");
		}
	} else {
		my $op1 = int(rand(9));
		return ($self, $op1);
	}
}


sub regnws {

	my $self = shift;
        my ( $username, $loca, $hd01, $title, $link, $hd02, $med, $news, $auth, $tmst, $uinas, $stat ) = @_;
	my $rsqn;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
	my $nwuser = user->new;
	my $idnas = rnews->idcone();
	my $csqn = $nwuser->regcom($username, $title);
	if ($stat eq "update" ) {
		$idnas = $uinas;
		$rsqn = $nwuser->regunws($username, $loca, $hd01, $title, $link, $hd02, $med, $news, $auth, $tmst, $idnas, $stat);
	} else {
		$tmst = `date "+%F %H:%M:%S"`;
		$rsqn = $nwuser->regunws($username, $loca, $hd01, $title, $link, $hd02, $med, $news, $auth, $tmst, $idnas);
	}
	my @rgns = $dbc->sqlstate($dbpg, $rsqn, "insert");
	#my $upfpage = rnews->compfpg2($username, $idnas);
	#my $cgqn = $dbc->sqlstate($dbpg, $csqn, "insert");
	$dbc->dbx($dbpg);
	return ($self, $rsqn);

}

sub delnews {

	my $self = shift;
        my ( $username, $idnas ) = @_;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $dsqn = $nwuser->delnws($username, $idnas);
	my $gsqn = $dbc->sqlstate($dbpg, $dsqn, "del");
	my $drsqn = "drop table \"$idnas\";";
	$gsqn = $dbc->sqlstate($dbpg, $drsqn, "drop");
	my $upfpage = rnews->compfpg2($username, $idnas);
	$dbc->dbx($dbpg);
	return ($self, $gsqn);

}

sub delitem {

	my $self = shift;
        my ( $username, $fo, %itm ) = @_;
        my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	if ($fo) {
		$fo = "fuser";
	}
	my $delisq = $nwuser->delitm($username, $fo, %itm);
	my $delirq = $dbc->sqlstate($dbpg, $delisq, "del");
	return ($delirq);
}

sub lnews {

	my $self = shift;
        my ( $username ) = @_;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
        my $lsqn = $nwuser->lsunws($username);
        my $lgns = $dbc->sqlstate($dbpg, $lsqn, "far");
	$dbc->dbx($dbpg);
        return ($self, $lgns);

}

sub upcoms {

	my $self = shift;
        my ( $username, $title, $comment, $inas ) = @_;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $gupsq = $nwuser->regcom($username, $title, $comment, $inas);
	my $guprs = $dbc->sqlstate($dbpg, $gupsq, "insert");
	$dbc->dbx($dbpg);
	return ($self, $guprs);

}

sub setlik {

	my $self = shift;
        my ( $username, $inas, $table ) = @_;
	my $numgq = "present!";
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $numsq = $nwuser->inlik( $username, $inas );
	if ($numsq) {
        	$numgq = $dbc->sqlstate($dbpg, $numsq, "insert");
	}
	my $sumsq = "select sum(milike) from \"$inas\";";
        my $sumrq = $dbc->sqlstate($dbpg, $sumsq, "f");
        my $inmks = "update $table set milike = \'$sumrq\' where idnas = \'$inas\';";
        my $inmkg = $dbc->sqlstate($dbpg, $inmks, "f");
	$dbc->dbx($dbpg);
	return ($self, $numgq);

}

sub chanid {

	my $self = shift;
        my ( $username, $indk ) = @_;
	my @cobj = ("Center", "Left1", "Left2", "Center2", "Down" );
	my @getar = undef;
	my @gidk = undef;
	my ($getsr, $getsq, $ntid) = undef;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	foreach (@cobj) {
		$getsq = $nwuser->getce($username, $_, 'fpage');
		$getsr = $dbc->sqlstate($dbpg, $getsq, "f");
		if ($getsr) {
			$getsr =~ /^(.*?),(.*?),/sgm;
			push(@gidk, "$1:$2");
			push(@getar, $getsr);
		}
	}
	if ($indk) {
		return ($self, \@gidk);
	} else {
		return ($self, \@getar);
	}
	$dbc->dbx($dbpg);

}

sub finduser {

	my $self = shift;
        my ( $uskeyword ) = @_;
	my ( $frpsq, $frgsq, $listh ) = undef;
	my $varsize = length($uskeyword);
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $ht = genhtml->new;
	my $uloged = $ht->getloged();
	if ( $varsize > 3 ) {
		$frpsq = $nwuser->usfind($uskeyword);
		$frgsq = $dbc->sqlstate($dbpg, $frpsq, "far");
		if ($frgsq) {
			my @iditem = @$frgsq;
		        my $nraf = $#iditem;
		        my $fraf = $#iditem + 1;
		        my $draf = $fraf / 3;
		        my $i = 0 ;
		        my $y = 0 ;
			foreach ($i=0; $i<$draf; $i++) {
			   if ($iditem[$y] ne $uloged) {
				my $photop = rnews->getufil($iditem[$y], 'profile', 'a');
				$listh .= "<input type=\"hidden\" id=\"uname$i\" value=\"$iditem[$y]\" />";
				$listh .= "$photop<div style=\"margin-top:20px;\" class=\"ltext\"><span class=\"ltext mlink\" onclick=\"ucrd([\'uname$i\'],[\'udet$i\']);\">$iditem[$y]";
				$y += 1;
				$listh .= " - $iditem[$y]";
				$y += 1;
				$listh .= " \/ $iditem[$y]</span><p id=\"udet$i\"></p></div>";
				$y += 1;
			   } else {
				$y += 3;
			   }
			}
		}
	}
	$dbc->dbx($dbpg);
	return ($self, $listh);
}

sub usfollow {

	my $self = shift;
        my ( $username, $usfoll ) = @_;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $idnas = rnews->idcone();
	my $usfsq = $nwuser->ufollow( $username, $usfoll, "1" );
	my $usfgq = $dbc->sqlstate($dbpg, $usfsq, "insert");
	my $usimsq = $nwuser->inmes($username, $usfoll, "1", $idnas, "The user $username, follow your news");
	my $usimgq = $dbc->sqlstate($dbpg, $usimsq, "insert");
	$dbc->dbx($dbpg);
	return ($self, $usfgq);

}

sub insact {

	my $self = shift;
        my ( $username, $newsact, $fuser ) = @_;
        my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $idnas = rnews->idcone();
	my ($usactgq ,$usactsq );
	if ($newsact) {
		$usactsq = $nwuser->regacti( $username, $newsact, $idnas, $fuser );
        	$usactgq = $dbc->sqlstate($dbpg, $usactsq, "insert");
	}
        $dbc->dbx($dbpg);
        return ($self, $usactgq);

}



sub wrmsg {

	my $self = shift;
	my ($username, $tous, $subject, $mbody, $toccuser, $tobccuser) = @_;
        my $nwuser = user->new;
	my ($wrmsq, $wrmsr) = undef;
	if (!$subject) {
		$subject = substr($mbody, 0, 25);
	}
	my $tosend = $nwuser->chkto($mbody);
	if ($tosend ne "not" && $tosend ne "xxx") {
		$tous = $tosend;
	} 
	my $mread = 1;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $inas = rnews->idcone();
	if ($tous && $mbody) {
		$wrmsq = $nwuser->inmes($username, $tous, $mread, $inas, $subject, $mbody, $toccuser, $tobccuser);
		$wrmsr = $dbc->sqlstate($dbpg, $wrmsq, "insert");
	}
	$dbc->dbx($dbpg);
        return ($self, $wrmsr);

}

sub getufil {


	my $self = shift;
        my ( $username, $imgtype, $minia, $imgid ) = @_;
	my $html;
	my $ixdir = substr($username, 0,1);
	my %psetup = config::settings::parmsetup;
	my $udsetup = $psetup{'dirsetup'} . "\/web\/users\/" . $ixdir . "\/" . $username;
	my $tysetup = $udsetup . "\/" . $imgtype;
        my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $gesql = $nwuser->getupfil($username, $imgtype, $imgid);
	my $gegql =  $dbc->sqlstate($dbpg, $gesql, "far");
	my @iditem = @$gegql;
	if ($iditem[1]) {
	#my $fbin = MIME::Base64::decode($iditem[1]);
	#my $finame = $tysetup . "\/" . $iditem[0];
	#my $hfname = "\/users\/" . $ixdir . "\/" . $username . "\/" . $imgtype . "\/" . $iditem[0];
		if ($minia) {
			$html = <<HB;
<img src="data:image/jpg;base64,$iditem[1]" style="align: left; width:45px; height:40px;" title="$username" />
HB
		} else {
			$html = <<HB;
<img src="data:image/jpg;base64,$iditem[1]"  style="float: left; width:90px; height:75px; margin-left:15px;" title="$username" />
HB
		}
	#if ( -f $finame ) { 
	#	$html = "<img src=\"\/tds\/$hfname\" class=\"imgp\" align=\"left\" width=\"75px\" height=\"75px\" alt=\"$iditem[0]\" \/>";
	#} elsif ( -d $tysetup ) {
	#	my $delfil = `rm -f $tysetup/*`;
	#	open (FILE, ">$finame");
	#	print FILE $fbin;
	#	close (FILE);
	#	$html = "<img src=\"\/tds\/$hfname\" class=\"imgp\" align=\"left\" width=\"75px\" height=\"75px\" alt=\"$iditem[0]\" \/>";
	#} else {
	#	my $makdir = `mkdir -p $tysetup`;
	#	open (FILE, ">$finame");
        #        print FILE $fbin;
        #        close (FILE);
        #        $html = "<img src=\"\/tds\/$hfname\" class=\"imgp\" align=\"left\" width=\"75px\" height=\"75px\" alt=\"$iditem[0]\" \/>";
		
	#}
		}
		elsif ($minia && !$iditem[1]) {
			$html =<<HB;
<img src="/tds/img/person.png" class="imgp" style="width:45px; height:40px;" title="$username" />
HB
		} else {
			$html =<<HB;
<img src="/tds/img/person.png" class="imgp" style="float: left; width:90px; height:75px;" title="$username" />
HB
		}
	return ($self, $html);

}

sub regver {

        my $self = shift;
        my ( $username ) = @_;
        my $upimg = Image::Magick->new;
	my $randst = new String::Random;
	my $text = $randst->randpattern("ccccc");
	my %psetup = config::settings::parmsetup;
        my $udsetup = "$psetup{'dirsetup'}\/web\/img\/";
	my $idimg = rnews->idcone();
	my $fimg = "$udsetup\/$idimg.gif";
	my $res = $upimg->Set(size=>'80x80');
	$res = $upimg->Read('xc:white');
	$res = $upimg->Draw(primitive=>'line', points=>"24,5 25,85", fill=>"green", x=>4, y=>10);
	$res = $upimg->Annotate(pointsize=>21, fill=>'black', text=>$text, x=>5, y=>50);
	$res = $upimg->Rotate(degrees=>20);
	$res = $upimg->Write($fimg);
	undef $upimg;
	return ($text, $idimg, $fimg);

}




sub uploadf {

	my $self = shift;
        my ( $username, $upfil, $imgtype, $inasg ) = @_;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $upimg = Image::Magick->new;
	#$file =~ m/^.+(\\|\/)(.*)/;
	my $name = $upfil;
	open(LOCAL, ">/tmp/$name");
	while(<$upfil>) {
		print LOCAL $_;
	}
	if ($imgtype eq "profile") {
		my $nnimg = "/tmp/$name";
		my $elimg = $upimg->Read($nnimg);
		$elimg = $upimg->Resize(width=>'90',height=>'75');
		$elimg = $upimg->Write('/tmp/appfile.png');
		unlink("/tmp/$name");
		$name = "appfile.png";
	}
	#undef $upimg;
	my $sizeimg = -s "/tmp/$name";
	my $imgbuff = "";
	open(FILE, "/tmp/$name");
	read (FILE, $imgbuff, $sizeimg);
	my $fbase64 = MIME::Base64::encode($imgbuff);
	my $imgsql = $nwuser->upfiles($username, $imgtype, $name, $fbase64, $inasg);
	my $imgisq = $dbc->sqlstate($dbpg, $imgsql, "insert");
        $dbc->dbx($dbpg);
	close(FILE);
	unlink("/tmp/$name");
	my $res = "uploaded ... ";
	return $res;

}

sub compfpg2 {

        my $self = shift;
	my ( $username, $idnas ) = @_;
	my ( $strh, $aids, $fprn, $fpmn, $key, $subnw ) = undef;
	my @upsq = ();
	my @clist = ( 'cc01', 'll01', 'cc02', 'll02', 'dd01' );
	my $i = 0;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	#$fpmn = $nwuser->alunws($username, $idnas);
	#$fprn = $dbc->sqlstate($dbpg, $fpmn, "far");
        my @iditem;
	my $dalwsq = "delete from ufpage where username = \'$username\';";
        $fprn = $dbc->sqlstate($dbpg, $dalwsq, "del");
	#$strh = "<h4>$iditem[0]</h4>";
	#$strh .= "<h2>$iditem[1]</h2>";
	#$strh .= "<h3>$iditem[2]</h3>";
	#$strh .= "<div>$iditem[3]</div>";
	#$subnw = substr($iditem[4], 0,200);
	#$strh .= "<div>$subnw ......</div>";
	#$fpmn = $nwuser->mupag("cc01", $username, $strh);
	#$fprn = $dbc->sqlstate($dbpg, $fpmn, "insert");
	$fpmn = $nwuser->alunws($username, "0", "order");
	$fprn = $dbc->sqlstate($dbpg, $fpmn, "far");
	if ($fprn) {
		my @lidnas = @$fprn;
		for (@lidnas) {
			$fpmn = $nwuser->alunws($username, $_);
                	$fprn = $dbc->sqlstate($dbpg, $fpmn, "far");
                	@iditem = @$fprn;
			$strh = '';
			$strh = "<h4>$iditem[0]</h4>";
       			$strh .= "<h2>$iditem[1]</h2>";
			$strh .= "<h3>$iditem[2]</h3>";
			$strh .= "<div>$iditem[3]</div>";
			$subnw = substr($iditem[4], 0,200);
       			$strh .= "<div>$subnw ......</div>";
			$fpmn = $nwuser->mupag($clist[$i], $username, $strh);
			$fprn = $dbc->sqlstate($dbpg, $fpmn, "insert");
			$i += 1;
		}
	} else {
		$dalwsq = "delete from ufpage where username = \'$username\';";
		$fprn = $dbc->sqlstate($dbpg, $dalwsq, "del");
	}
	$dbc->dbx($dbpg);
	return ($self, "OK");

}


sub compfpg {

	my $self = shift;
	my ( $username, $title, $Center, $Left1, $Left2, $Center2, $Down ) = @_;
	my %clist = ( cc01 => 'c_news', ll01 => 'l1_news', cc02 => 'c2_news', ll02 => 'l2_news', dd01 => 'd_news' );
	my ( $strh, $aids, $fprn, $fpmn, $key, $subnw ) = undef;
	my ( @iditem, @htmlfp, @allid, @typeid ) = undef;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
        my $fpqn = $nwuser->fupag($username, $title, $Center, $Left1, $Left2, $Center2, $Down);
	if ($Center || $Left1 || $Left2 || $Center2 || $Down) {
		$fprn = $dbc->sqlstate($dbpg, $fpqn, "insert");
		$aids = rnews->chanid($username, '1');
		@allid = @$aids;
		foreach (@allid) {
			if ($_) {
				($fpmn, $fprn) = '';
				@typeid = split(/:/, $_);
				$clist{$typeid[1]} = 'insert';
				$fpmn = $nwuser->alunws($username, $typeid[0]);
				$fprn = $dbc->sqlstate($dbpg, $fpmn, "far");
				@iditem = @$fprn;
				$strh = "<h4>$iditem[0]</h4>";
				$strh .= "<h2>$iditem[1]</h2>";
				$strh .= "<h3>$iditem[2]</h3>";
				$strh .= "<div>$iditem[3]</div>";
				$subnw = substr($iditem[4], 0,200);
				$strh .= "<div>$subnw ......</div>";
				$fpmn = $nwuser->mupag($typeid[1], $username, $strh);
				$fprn = $dbc->sqlstate($dbpg, $fpmn, "insert");
			}
		}
		foreach $key (keys %clist) {
			($fpmn, $fprn) = '';
                        if ($clist{$key} ne 'insert') {
				$fpmn = $nwuser->mupag($key, $username, '<div></div>');
				$fprn = $dbc->sqlstate($dbpg, $fpmn, "insert");	
			}
		}
		$fprn = "First paged!";
	} else {
		$fprn = "select at least one news";
	}
	$dbc->dbx($dbpg);
	return ($self, $fprn);

}

sub myfolh {

	my $self = shift;;
        my ( $username ) = @_;
        my $us = user->new;
        my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $folsq = $us->myfollow($username, 'flwr');
        my $folsr = $dbc->sqlstate($dbpg, $folsq, "far");
        my @listf = @$folsr;
        my $y = 0;
        my $lsthtml = "<div><input type=\"hidden\" id=\"fdlmt\" value=\"5\"/><input type=\"hidden\" id=\"fofst\" value=\"0\"/><input type=\"hidden\" id=\"fnext\" value=\"fol\"/>";
        foreach (@listf) {
                $y += 1;
                my $photop = rnews->getufil($_, 'profile', 'a');
                $lsthtml .=<<HB1;
<input type="hidden" id="fuser$y" value="$_"/>
<span style="width:150px; margin-left:10px;" class="mlink_0" onclick="acti([ \'fuser$y\','fdlmt','fofst','fnext' ], [ 'resu' ]);">$photop</span>
HB1
        }
        $lsthtml .= "</div>";
        $dbc->dbx($dbpg);
        return ($self, $lsthtml);

}




1;
