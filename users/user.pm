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
use Digest::MD5 qw(md5 md5_hex md5_base64);

use lib '../';

use config::settings;
use news::rnews;
use session::conndb;
use session::consmtp;

package user;



sub new {
    my $class = shift;
    return bless {}, $class;
}

sub ckstr { 

	my $self = shift;
        my ( $sparse, $mod ) = @_;
	my ( $aps, $haps, $str, $rstr) = undef;
	my @spstr = split(/\ /, $sparse);
	foreach (@spstr) {
		if ($_ =~ /http|www/ ) {
			$_ =~ /(http|www)(.+)/;
                	$aps = $1 . $2;
			if ($aps =~ /http/) {
				$haps = $aps;
			} else {
				$haps = "http\:\/\/" . $aps;
			}
			$sparse =~ s/$aps/<a href=\"$haps\" target=\"_blank\">$aps<\/a>/g;
		}
		if (length($_) > 55 ) {
			my $cnt = length($_) / 55 ;
			$str = $_;
			$rstr = $_;
			my ($i) = 1;
			my ($e) = 55;
			while ($i <= int($cnt)) {
				substr($str, $e, 1) = "<br/>";
				$i += 1;
				$e = 55 * $i;
			}
			$sparse =~ s/$rstr/$str/g;
		} 
	}

	if ( $mod eq "i" ) {
		$sparse =~ s/\'/''/g;
		$sparse =~ s/\\/\\\\/g;
		my $dsparse = Encode::encode("utf-8", $sparse);
		return ( $self, $dsparse );
	} 
	if ( ($mod eq "k") && ($sparse =~ /\\|\/|\'|\"|\^|\(|\)|\||\$|è|é|à|ù|°|ò|ç|@|;|:|<|>|£|!|£|%|&|=|\{|\}/) ) {
		$mod = 1;
		return ( $self, $mod );
	} else {
		$mod = 0;
                return ( $self, $mod );
	}
}

sub chkto {

	my $self = shift;
        my ($tos) = @_;
	my @spstr = split(/\ /, $tos);
	my $resp = "xxx";
	my $dbc = conndb->new;
        my $dbh = $dbc->dbuse();
        if ($spstr[0] =~ /\@/) {
                $spstr[0] =~ /\@(.+)/;
                my $userq = user->auser($1);
        	my $userg = $dbc->sqlstate($dbh, $userq, "f");
		if ($userg) {
			$resp = $userg;
		} else {
			$resp = "not";
		}
        }
	return ( $self, $resp );
}

sub vnews {

	my $self = shift;
        my ($username, $inas, $tdcreted ) = @_;
	my $sql = undef;
        $sql = "select location, head01, title, head02, media, news, timest, author from news where username = \'$username\' and idnas = \'$inas\';";
	return ($self, $sql);

}


sub cntf {

	my $self = shift;
        my ( $compare, $cell, $table ) = @_;
	my $sql = undef;
        $sql = "select count($cell) from $table where $cell = \'$compare\' ;";
	return ($self, $sql);

}

sub cocom { 

	my $self = shift;
        my ( $username, $com, $inas) = @_;
        my $sql = undef;
	foreach ( $com ) {
                $_ = user->ckstr( $_, "i" );
        }
        #$sql = "select count($com) from comments where idnas = \'$inas\' and username = \'$username\';";
        $sql = "select count($com) from comments where idnas = \'$inas\';";
        return ($self, $sql);

}

sub fwait {

	my $self = shift;
        my ($username, $ufoll) = @_;
	#my $sql = "select swait from follow where username = \'$username\' and userfollow = \'$ufoll\' and swait = \'1\';";
	my $sql = "select userfollow from follow where username = \'$username\' and userfollow = \'$ufoll\' ;";
	return ($self, $sql);

}

sub getce {

	my $self = shift;
        my ( $compare, $cell, $table, $rcount, $eecomp ) = @_;
	my $sql = undef;
	if ($rcount) {
        	$sql = "select count($cell) from $table where touser = \'$compare\' and $eecomp = \'$rcount\';";	
	} else {
		$sql = "select $cell from $table where username = \'$compare\';";
	}
	return ($self, $sql);

}

sub auser {

        my $self = shift;
        my ( $username ) = @_;
	my $sql = undef;
        $sql = "select username from users where username = \'$username\' ;";
        return ($self, $sql);

}

sub euser {

        my $self = shift;
        my ( $uemail ) = @_;
        my $sql = undef;
        $sql = "select email from users where email = \'$uemail\' ;";
        return ($self, $sql);

}


sub puser {

	my $self = shift;
        my ( $username, $password ) = @_;
	my $md5pass = user->pwdmd5($username, $password);
	$password = $md5pass;
        my $sql = "select password from session where users = \'$username\' and password = \'$password\';";
        return ($self, $sql);

}

sub pwdmd5 {

	my $self = shift;
        my ( $username, $password ) = @_;
	my $copwd = Digest::MD5->new;
	my $md5pwd = $copwd->add($password);
	$md5pwd = $copwd->hexdigest;
	return ($self, $md5pwd);
}

sub chpwd {

	my $self = shift;
        my ( $username, $password, $npwdx, $npwdy ) = @_;
	my $res = undef;
	my $dbc = conndb->new;
        my $dbh = $dbc->dbuse();
	my $ckpws = user->puser($username, $password );
        my $ckpwr = $dbc->sqlstate($dbh, $ckpws, "f");
	if ($ckpwr && $npwdx eq $npwdy) {
		my $md5pass = user->pwdmd5($username, $npwdx);
		$ckpws = "update session set password = \'$md5pass\';";
		$ckpwr = $dbc->sqlstate($dbh, $ckpws, "update");
		$res = "<b>Password Changed !!!</b>";
		return ($self, $res);
	}
	if (!$ckpwr) { $res = "<b>old password invalid ... </b>";}
	if ($npwdx ne $npwdy) { $res .= "<b>the passwords not equal ... </b>";}
	return ($self, $res);
}

sub acted {

	my $self = shift;
        my ( $username, $idact, $upact, $bok, $text) = @_;
	my $sql = "select active from session where users = \'$username\' and active = \'$idact\';";
	if ($upact eq "reqact" && $bok eq $text) {
		$sql = "update session set active = \'1\' where users = \'$username\' and active = \'$idact\';";
	}
	if ($upact eq "ckact" ) {	
		$sql = "select active from session where users = \'$username\' and active = \'1\';";
	}
	return ($self, $sql);

}

sub reguser { 

	my $self = shift;
        #my ( $name, $surname, $username, $birthday, $email, $alias, $gender, $location, $country, $note, $password, $ipaddress, $session) = @_;
        my ( $name, $surname, $email, $username, $password, $ipaddress, $bok, $text, $session, $birthday, $alias, $gender, $location, $country, $note) = @_;
	my ( $drs, $sqln, $sqlu, $sqlp, $dbc, $dbh, $ausc, $eusc, @eus, @aus, $cktxt ) = undef;
	#my @txtr = ('Name', 'Surname', 'gender', 'birthday', 'email', 'Username', 'Password', 'location', 'country' );
	my @txtr = ('Name', 'Surname', 'email', 'Username', 'Password');
	my $usnews = rnews->new();
	my $smtpc = consmtp->new();
	my %psetup = config::settings::parmsetup;
	my $i = 0;
	foreach ( $name, $surname, $alias, $gender, $location, $country, $note ) {
		$_ = user->ckstr( $_, "i" );
	}
	#foreach  ( $name, $surname, $gender, $birthday, $email, $username, $password, $location, $country ) {
	foreach  ( $name, $surname, $email, $username, $password ) {
        	if (!$_) { 
			$cktxt .= "<b>The $txtr[$i] is mandatory !</b><br>"; 
		}
	$i += 1;
        }
	if ($username =~ /\\|\/|\'|\"|\^|\(|\)|\||\$|è|é|à|ù|°|ò|ç|@|;|:|<|>|£|!|£|%|&|=|§|\{|\}/) {
		$drs = "<b>insert an invalid char in username !!! </b><br>";
	}
	my $sizepwd = length($password);
	if ($sizepwd < 8) {
		$drs .= "<b>insert minimun 8 chars in password !!! </b><br>";
	}
	my $md5pass = user->pwdmd5($username, $password);
	$password = $md5pass;
	my $idact = $usnews->idcone();
	$drs .= $cktxt; 
	if ($drs) {
		$drs .= "<b> .....</b><br>";
	} else {
		$sqln = "insert into notes (unote, gender, nazionality, location, note) values (\'$username\', \'$gender\', \'$location\', \'$country\', \'$note\');";
		$sqlu = "insert into users (name, surname, username, birthday, email, alias) values (\'$name\', \'$surname\', \'$username\', \'$birthday\', \'$email\', \'$alias\');";
		$sqlp = "insert into session (users, password, ipaddress, session, active) values (\'$username\', \'$password\', \'$ipaddress\', \'$session\', \'0_$idact\');";
		my $datas = "Follow this link $psetup{'domain'}\/regu.pl?$username\?0_$idact to activate your account";
		$dbc = conndb->new;
		$dbh = $dbc->dbuse();
		$ausc = user->auser($username);
		@aus = $dbc->sqlstate($dbh, $ausc, "f");
		if ($aus[1]) { $drs = "<b>username already exist!</b><br>";}
		$eusc =  user->euser($email);
		@eus = $dbc->sqlstate($dbh, $eusc, "f");
		if ($eus[1]) { $drs .= "<b>email already exist!</b><br>";}
		#if (!$aus[1] && !$eus[1] && $bok eq $text) {
		if (!$aus[1] && !$eus[1]) {
			$drs = $dbc->sqlstate($dbh, $sqln, "i");
			$drs = $dbc->sqlstate($dbh, $sqlu, "i");
			$drs = $dbc->sqlstate($dbh, $sqlp, "i");
			#$drs = $smtpc->c_smtp($username, $email, "Welcome to lepre ...", $datas);
			$drs = "xx";
		#} elsif ($bok ne $text) {
		#	$drs = "<b>Error !!!!!</b><br>";
		} else {
			$drs = $drs;
		}
		$dbc->dbx($dbh);
	}
	return ($self, $drs);

}

sub deldis {

	my $self = shift;
        my ( $username, $sta ) = @_;
	my ($sql, %dsql) = undef;
	if ($sta eq 'disable') {
		$sql = "update session set active = \'0\' where users = \'$username\';";
		return ($self, $sql);
	}
	if ($sta eq 'delete') {
		%dsql = ( 'dsq1' => "delete from notes where unote = \'$username\';",
			  'dsq2' => "delete from users where username = \'$username\';",
			  'dsq3' => "delete from session where users = \'$username\';",
			  'dsq4' => "delete from activity where users = \'$username\';",
			  'dsq5' => "delete from comments where users = \'$username\';",
			  'dsq6' => "delete from follow where users = \'$username\';",
			  'dsq7' => "delete from fpage where users = \'$username\';",
			  'dsq8' => "delete from home where users = \'$username\';",
			  'dsq9' => "delete from homen where users = \'$username\';",
			  'dsq10' => "delete from ilik where users = \'$username\';",
			  'dsq11' => "delete from messages where users = \'$username\';",
			  'dsq12' => "delete from news where users = \'$username\';",
			  'dsq13' => "delete from ufpage where users = \'$username\';",
			  'dsq14' => "delete from upfiles where users = \'$username\';"
		);
		return ($self, \%dsql);
	}

}

sub edup {

	my $self = shift;
        my ( $username ) = @_;
	my $sql = "select users.name, users.surname, notes.gender, users.birthday, notes.location, notes.nazionality, users.email, users.alias, notes.note from users inner join notes on users.username = notes.unote where username = \'$username\';";
        return ($self, $sql);

}

sub edupd {

	my $self = shift;
        my ( $username, $name, $surname, $gender, $birthday, $location, $nazionality, $email, $alias, $note ) = @_;
	foreach ($name, $surname, $gender, $birthday, $location, $nazionality, $email, $alias, $note ) {
		$_ = user->ckstr( $_, "i" );
	}
	my %var1 = (username => $username, name => $name, surname => $surname, birthday => $birthday, email => $email, alias => $alias );
	my %var2 = (username => $username, gender => $gender, nazionality => $nazionality,  location => $location, note => $note );
	my %sql = ();
	my ($key, $str1, $str2);
	foreach $key (keys %var1) {
		if ($var1{$key} && $key ne "username") {
			$str1 .= "$key = \'$var1{$key}\',";
		}
		
	}
	foreach $key (keys %var2) {
                if ($var2{$key} && $key ne "username") {
                        $str2 .= "$key = \'$var2{$key}\',";
                }
                
        }
	$str1 =~ s/\,$//;
	$str2 =~ s/\,$//;
	if ($str1) {
		$sql{sql1} = "update users set $str1 where username = \'$username\';";
	}
	if ($str2) {
		$sql{sql2} = "update notes set $str2 where unote = \'$username\';";
	}
	return ($self, \%sql);

}

sub usercard {
	
	my $self = shift;
	my ( $username ) = @_;
	my $sql = "select users.name, users.surname, users.email, users.birthday, notes.location from users inner join notes on users.username = notes.unote where username = \'$username\';";
	return ($self, $sql);
	
}

sub vusmess {

	my $self = shift;
	my ( $username, $modal, $inas ) = @_;
	my $sql = undef;
	if ( $modal eq "r" ) {
		$sql = "select username, subject, mbody, timest from messages where idnas = \'$inas\';";
	} else {
        	$sql = "select idnas, username, subject, timest, mread from messages where touser = \'$username\';";
	}
	return ($self, $sql);

}

sub regunws {

	my $self = shift;
	my ( $username, $loca, $hd01, $title, $link, $hd02, $med, $news, $auth, $timest, $idnas, $stat ) = @_;
	my %var1 = (location => $loca, head01 => $hd01, title => $title, link => $link, head02  => $hd02, media => $med, news => $news, author => $auth);
	my ($key, $str, $sql);
	foreach ( $loca, $hd01, $title, $link, $news, $hd02, $med, $auth ) {
                $_ = user->ckstr( $_, "i" );
        }
	if ($stat eq "update") {
		foreach $key (keys %var1 ) {
			if ($var1{$key}) {
				$str .= "$key = \'$var1{$key}\',";
			}
				
        	}
		$str =~ s/\,$//;
		$sql = "update news set $str where username = \'$username\' and idnas = \'$idnas\';";
	} else {
		$sql = "insert into news (username, location, head01, title, link, head02, media, news, author, timest, idnas) values (\'$username\', \'$loca\', \'$hd01\', \'$title\', \'$link\', \'$hd02\', \'$med\', \'$news\', \'$auth\', \'$timest\', \'$idnas\');";
	}
	return ($self, $sql);

}

sub delitm {

	my $self = shift;
        my ( $username, $fo, %rows) = @_;
	my $sql = "delete from $rows{table} where username = \'$username\' and $rows{items};";
	if ($fo) {
		$sql = "delete from $rows{table} where $fo  = \'$username\' and $rows{items};";
	}
	return ($self, $sql);

}

sub delnws {

	my $self = shift;
        my ( $username, $idnas ) = @_;
	my $sql = "delete from news where username = \'$username\' and idnas = \'$idnas\';";
	return ($self, $sql);

}

sub regacti {

	my $self = shift;
        my ( $username, $newsact, $inas, $fuser ) = @_;
	my $tmst = `date "+%F %H:%M:%S"`;
	foreach ( $newsact ) {
                $_ = user->ckstr( $_, "i" );
        }
	my $sql;
	if ($fuser) {
		$sql = "insert into activity (username, news, timest, idnas, fuser) values (\'$username\', \'$newsact\', \'$tmst\', \'$inas\', \'$fuser\');";
	} else {
		$sql = "insert into activity (username, news, timest, idnas, fuser) values (\'$username\', \'$newsact\', \'$tmst\', \'$inas\', \'\');";
	}
	return ($self, $sql);

}

sub vieact {

	my $self = shift;
        my ( $username, $lmt, $ofst, $fol ) = @_;
	#if (!$lmt && !$ofst) { 
	#	$lmt = 5;
	#	$ofst = 0;
	#}
	my ($sql, @listuf, $keyst, $lst) = undef;
	my $dbc = conndb->new;
        my $dbh = $dbc->dbuse();
	my $getufq = "select userfollow from follow where username = \'$username\' and swait = '0';";
	my $getufr = $dbc->sqlstate($dbh, $getufq, "far");
	if ($getufr) {
		$lst .= "$username";
		foreach (@$getufr) {
			$lst .= "\|$_";
		}
		$keyst = '~* ' . "\'" . $lst . "\'";
	} else {
		$keyst = "= \'$username\'";
	}
	if ($fol eq 'fol') {
		$sql = "select fuser, username, idnas, timest, news from activity where username = \'$username\' order by timest desc limit $lmt offset $ofst;";
	} elsif ($fol eq 'rep') {
		$sql = "select fuser, username, idnas, timest, news from activity where fuser = \'$username\'  order by timest desc limit $lmt offset $ofst;";
	} else {
		$sql = "select fuser, username, idnas, timest, news from activity where username $keyst order by timest desc limit $lmt offset $ofst;";
	}
	return ($self, $sql);

}

sub regcom {

	my $self = shift;
        my ( $username, $title, $comment, $idnas ) = @_;
	if (!$comment) {
		$comment = ' ';
	}
	foreach ( $comment, $title ) {
                $_ = user->ckstr( $_, "i" );
        }
	my $sql = "insert into comments (username, title, comment, idnas) values (\'$username\', \'$title\', \'$comment\', \'$idnas\');";
        return ($self, $sql);

}

sub upcom {

	my $self = shift;
        my ( $username, $title, $comment ) = @_;
	foreach ( $title, $comment ) {
                $_ = user->ckstr( $_, "i" );
        }
        my $sql = "update comments set comment = \'$comment\' where title = \'$title'\ and username = \'$username\';";
        return ($self, $sql);

}

sub inlik {

	my $self = shift;
        my ( $username, $idnas ) = @_;
	my ($sql, $numgq, $numsq, $cstab, $crtab) = undef;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
	my $ftab = "select tablename from  pg_tables where tablename = \'$idnas\';";
	my $frtab = $dbc->sqlstate($dbpg, $ftab, "f");
	if (!$frtab) {
		$cstab = "create table \"$idnas\" ( idnk serial NOT NULL, milike bigint, username character varying(50) NOT NULL, PRIMARY KEY(idnk));";
		$crtab = $dbc->sqlstate($dbpg, $cstab);
                $sql = "insert into \"$idnas\" (username, milike) values ( \'$username\', \'1\');";
	} else {
		$numsq = "select username from \"$idnas\" where username = \'$username\';";
       		$numgq = $dbc->sqlstate($dbpg, $numsq, "f");
		if (!$numgq) {
		#	int($numgq);
		#	$numgq += 1;
		#	$sql = "update \"$idnas\" set milike = \'$numgq\' where username = \'$username\';";
		#} else {
			$sql = "insert into \"$idnas\" (username, milike) values ( \'$username\', \'1\');";
		}
	}
	$dbc->dbx($dbpg);
	return ($self, $sql);

}

sub vcomm {

	my $self = shift;
        my ( $username, $inas ) = @_;
        #foreach ( $title ) {
        #        $_ = user->ckstr( $_, "i" );
        #}
	#my $sql = "select username, comment from comments where idnas = \'$inas'\ and username = \'$username\';";
	my $sql = "select username, comment from comments where idnas = \'$inas'\ ;";
	return ($self, $sql);

}


sub vlik {

	my $self = shift;
        my ( $username, $inas, $table ) = @_;
	my $sql = "select milike from $table where idnas = \'$inas'\;";
	return ($self, $sql);

}

sub lsunws {

	my $self = shift;
	my ( $username ) = @_;
	my $sql = "select idnas, timest, title, news from news where username = \'$username\';";
	return ($self, $sql);
	
}

sub alunws {

        my $self = shift;
        my ( $username, $inds, $lmt ) = @_;
	my $sql = undef;
	if (!$lmt && $inds) {
        	$sql = "select head01, title, head02, media, news from news where username = \'$username\' and idnas = \'$inds\';";
	} 
	elsif ($lmt eq "order" ) {
		$sql = "select idnas from news where username = \'$username\' order by timest desc limit 5;";	
	} else {
        	$sql = "select idnas, title, media, news from news where username = \'$username\';";
	}
        return ($self, $sql);

}

sub fupag {

	my $self = shift;
        my ( $username, $tit, $Cent, $Lef1, $Lef2, $Cent2, $Dwn ) = @_;
	foreach ( $tit, $Cent, $Lef1, $Lef2, $Cent2, $Dwn ) {
                $_ = user->ckstr( $_, "i" );
        }
	my @cobj = ("title", "Center", "Left1", "Left2", "Center2", "Down" );
	my $i = 0;
	my ( $istr, $sql) = undef;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
	my $counts = user->cntf($username, 'username', 'fpage');
	my $countr = $dbc->sqlstate($dbpg, $counts, "f");
	if ($countr eq '1') {
		foreach ( $tit, $Cent, $Lef1, $Lef2, $Cent2, $Dwn ) {
			if ($_) {
				$istr .= "$cobj[$i] = \'$_\',";
			} else {
				$istr .= "$cobj[$i] = \'\',";
			}
			$i +=1;
		}
		$istr =~ s/,$//;
		$sql = "update fpage set $istr WHERE username = \'$username\';";
	} else {
        	$sql = "insert into fpage (username, title, Center, Left1, Left2, Center2, Down) values (\'$username\', \'$tit\', \'$Cent\', \'$Lef1\', \'$Lef2\', \'$Cent2\', \'$Dwn\');"; 
	}
	$dbc->dbx($dbpg);
	return ($self, $sql);

}

sub mupag {

	my $self = shift;
        my ( $idk, $username, $typeid ) = @_;
	foreach ( $typeid ) {
                $_ = user->ckstr( $_, "i" );
        }
	my %clistup = ( 'c_news' => 'cc01', 'l1_news' => 'll01', 'c2_news' => 'cc02', 'l2_news' => 'll02', 'd_news' => 'dd01' );
	my ( $sql, $key ) = undef;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
	my $counts = user->cntf($username, 'username', 'ufpage');
	my $countr = $dbc->sqlstate($dbpg, $counts, "f");
	if ($countr eq '1') {
		foreach $key (keys %clistup) {
			if ( $clistup{$key} eq $idk ) {
				$sql = "update ufpage set $key = \'$typeid\' WHERE username = \'$username\';";
			}
		}
	} else {
		foreach $key (%clistup) {
                        if ( $clistup{$key} eq $idk ) {
				$sql = "insert into ufpage ( username, $key ) values (\'$username\', \'$typeid\');";
			}
		}
	}
	$dbc->dbx($dbpg);
	return ($self, $sql);

}

sub getfpg {

	my $self = shift;
        my ( $username, $itobj ) = @_;
	my $sql = "select $itobj from fpage where username = \'$username\';";
	return ($self, $sql);

}

sub vieufpg {

	my $self = shift;
        my ( $username ) = @_;
        my $sql = "select c_news, l1_news, c2_news, l2_news, d_news from ufpage where username = \'$username\';";
	return ($self, $sql);

}

sub usfind {

	my $self = shift;
        my ( $uskeyword ) = @_;
	my $sql = "select username, name, surname from users where username ~* \'$uskeyword\' or name ~* \'$uskeyword\' or surname ~* \'$uskeyword\';";
	return ($self, $sql);
}

sub ufollow {

	my $self = shift;
	my ( $username, $usfoll, $upw ) = @_;
	my $sql = "insert into follow (username, userfollow, swait) values (\'$username\', \'$usfoll\', \'0\');";
	if ($upw eq "0") {
		$sql = "update follow set swait = \'0\' where username = \'$username\' and userfollow = \'$usfoll\';";
	}
	if ($upw eq "c") {
                $sql = "select count(swait) from follow where username = \'$username\' and swait = \'0\';";
	}
	return ($self, $sql);

}

sub myfollow {

	my $self = shift;
        my ( $username, $flwr ) = @_;
	my $sql = "select userfollow from follow where username = \'$username\';";
	if ($flwr) {
		$sql = "select username from follow where userfollow = \'$username\';";
	}
	return ($self, $sql);

}

sub upfiles { 
	
	my $self = shift;
        my ( $username, $imgtype, $imgname, $imgbuff, $imgid ) = @_;
	my $sql = undef;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
	my $cntsq = "select count(imgtype) from upfiles where username = \'$username\' and imgid = \'$imgid\';";
	my $cntsr = $dbc->sqlstate($dbpg, $cntsq, "f");
	if ($cntsr eq '1') {
		$sql = "update upfiles set imgname = \'$imgname\', imgfile = \'$imgbuff\' where username = \'$username\' and imgid = \'$imgid\';";
	} else {
		$sql = "insert into upfiles (imgtype, imgname, imgfile, username, imgid) values (\'$imgtype\', \'$imgname\', \'$imgbuff\', \'$username\', \'$imgid\' );";
	}
	return ($self, $sql);

}

sub getupfil {

	my $self = shift;
        my ( $username, $imgtype, $imgid ) = @_;
	my $sql;
	if ($imgid) {
        	$sql = "select imgname, imgfile from upfiles where username = \'$username\' and imgtype = \'$imgtype\' and imgid = \'$imgid\';";
	} else {
		$sql = "select imgname, imgfile from upfiles where username = \'$username\' and imgtype = \'$imgtype\' ;";
	}
	return ($self, $sql);

}

sub inmes {
	
	my $self = shift;
        my ( $username, $tous, $mread, $inas, $subject, $mbody, $toccuser, $tobccuser) = @_;
	foreach ( $subject, $mbody ) {
                $_ = user->ckstr( $_, "i" );
        }
	my $tmst = `date "+%F %H:%M:%S"`;
	my $sql = "insert into messages (mread, touser, toccuser, tobccuser, subject, mbody, username, timest, idnas) values ( \'$mread\', \'$tous\', \'$toccuser\', \'$tobccuser\', \'$subject\', \'$mbody\', \'$username\', \'$tmst\', \'$inas\');";
	return ($self, $sql);

}


1;
