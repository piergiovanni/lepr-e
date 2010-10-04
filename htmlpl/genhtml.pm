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
use CGI;

use lib '../';

use config::settings;
use session::conndb;
use session::sess;
use users::user;
use news::rnews;
use lang::langua;

package genhtml;


sub new {
    my $class = shift;
    return bless {}, $class;
}

sub getloged {

	my $self = shift;
	my $hq = CGI->new;
	my $cgis = sess->new;
	my $sed = $cgis->crts("reload", "reload", $hq);
	my $userlog = $sed->param('Username');
	return ( $self, $userlog);
}

sub homen {

	my $self = shift;
	my ( $vuser ) = @_;
	my $ulog = genhtml->getloged();
	my $unw = rnews->new;
        my $hb2 = undef;
        my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
        my $codmd5 = $nwuser->pwdmd5('',$ulog);
        #my $vieactq = $nwuser->vieact( $vuser, '1' );
        #my $vieactg = $dbc->sqlstate($dbpg, $vieactq, "far");
        #my @iditem = @$vieactg;
        #$hb2 .= "<td><div>$iditem[1] ";
        #$hb2 .= "<b>$iditem[2]</b></div></td>";
	my $photop = $unw->getufil($vuser, 'profile');
	my $myfol_u = $unw->myfolh($vuser);
	my $vucard = genhtml->ucard($vuser, 'e');
	my $mesgq = $nwuser->getce($vuser, "touser", "messages", "1", "mread");
	my $mesrq  = $dbc->sqlstate($dbpg, $mesgq, "f");
	my $cofolsq = $nwuser->ufollow($vuser, "none", "c");
	my $cofolgq = $dbc->sqlstate($dbpg, $cofolsq, "f");
	my $raf = $unw->lnews( $vuser );
	#my $resp = genhtml->hlnews($raf, $vuser);
	my $resp = genhtml->activ($vuser);

#<b><div id="linews"  onclick="ln([ 'username' ], [ 'resu', 'firstp' ]);gis([ 'username' ], [ onElement ]);">List News</div> </b>

        my $hb=<<HB1;
<table class="t2">
  <tbody>
    <tr>
      <td><div>$photop $vucard</div></td>
      <td><input type="hidden" id="username" value="$vuser"/><input type="hidden" id="rfl" value="rep"/><input type="hidden" id="nov" value="0"/></td>
      <td class="td001" ><a style="margin-left:15px; "href="/tellyou/homenews.pl"><img class="imgp" src="/tds/img/hm_img.png"/></a>
      <a style="margin-left:15px;" href="/tellyou/homenews.pl?esci"><img class="imgp" src="/tds/img/lgo_img.png"/><a style="margin-left:15px;" href="#" onclick="chp([ 'NO_CACHE' ], [ 'resu' ]);"><img class="imgp" src="/tds/img/set_img.png"/></a><a style="margin-left:15px;" href="#" onclick="acti([ 'nov','nov','nov','rfl','NO_CACHE' ], [ 'resu' ]);">\@$vuser</a></td>
    </tr>
</tbody>
</table>
<table style="border-color: #9ADF81; border-width: 1px; border-style:solid;" class="t1">
  <tbody>
    <tr><td></td>
      <td ><span class="bg_tbs mlink_0"><a target="_blank" href="/tellyou/userfp.pl?$vuser?acti">My News Page</a></span><!--/td--> 
      <!--td class="td04"--><a style="margin-left:15px;" class="bg_tbs mlink_0" id="act"  onclick="acti([ 'NO_CACHE' ], [ 'resu' ]);"><b>Activities</b></a><!--/td-->
      <!--td class="td04"><a style="margin-left:15px;" class="bg_tbs mlink_0" id="irn"  value="regne" onclick="vrn([ 'NO_CACHE'  ], [ 'resu' ]);"><b>Insert News</b></a></td-->
      <!--td class="td04"--><a style="margin-left:15px;" class="bg_tbs mlink_0" id="flwrs" onclick="flws([ 'NO_CACHE'  ], [ 'resu' ]);"><b>Following <sup>($cofolgq)</b></sup></a><!--/td-->
      <!--td class="td04"--><a style="margin-left:15px;" class="bg_tbs mlink_0" id="msg" onclick="mesg([ 'NO_CACHE'  ], [ 'resu' ]);"><b>Messages <sup>($mesrq)</sup></b></a><!--/td-->
      <!--td class="td04"--><a style="margin-left:15px;" class="bg_tbs mlink_0" id="findr" value="findrep" onclick="fdrp([ 'findr', 'NO_CACHE'  ], [ 'txtfindr' ]);"><b>Find Users</b></a><!--/td--> 
      <!--td class="td04"--><!--/td-->
      <!--td class="td04"--></td>
      <td></td>
    </tr>
    <tr>
      <td><div id="vacti" ></div><td></td><td></td></td>
    </tr>
    <tr>
      <td></td>
      <td><td></td><div id="txtfindr"></div><td></td></td>
    </tr>
    <tr>
      <td></td>
      <td><div id="inf"></div></td><td></td>
    </tr>
    <tr><td style="width:180px;"></td><td style="border-color: #E6FFC2; border-width: 1px; border-style:solid;" class="t3" id="resu">$resp</td><td><div style="margin-top:15px;" >$myfol_u</div></td></tr>
</tbody>
</table>
HB1
	#$hb .= "<br/><table class=\"t3\"><tbody id=\"resu\"  >$resp</tbody></table>";
	#$hb .= "<br/><div class=\"t3\" id=\"resu\">$resp</div>";

        return ( $hb );
}


sub login {

	my $self = shift;
	my ($err) = @_;
	my $leng = langua->new;
	my $wH = $leng->weHome('en');
	my $pr = $leng->specPrj('en');
        my $hb=<<HB1;
<table>
<tbody id="all">
<tr>
<td>
<div style="font-size : large; margin-left:100px; margin-top:30px; border-bottom-color: #E6FFC2; border-bottom-width: 3px; border-bottom-style:solid;">
<h3>Lepr-e flash News</h3>
<img src="/tds/img/run_lepre.png" width="145" height="100"/><sub style="color:gray;">Developer Version</sub>
</div>
</td>
<td>
<div>$err</div>
<div style="font-size : large; margin-left:130px; margin-top:30px;">
      <pre><span><b>Username</b></span><span>   <INPUT type="text" name="Username" id="Username"></span></pre>
      <pre><span><b>Password</b></span><span>   <INPUT type="password" name="password" id="password"></span></pre>
      <pre id="txte"></pre>
      <pre><span><input class="butt dbord mlink_0" type="submit" id="login" value="login" /> <a href="#" onclick="vtxe(['NO_CACHE'],['txte']);">forgot password</a></pre>
</div>
<div style="font-size : large; margin-left:130px; margin-top:30px; ">
<a href="/tellyou/regu.pl">Create New Account</a>
</div>
</td><td></td></tr>
</tbody>
</table>
<div>
<div style="float:left; width:380px; text-align:justify; margin-top:80px; margin-left:100px; ">$wH</div>
<div style="float:left; width:380px; text-align:justify; margin-top:80px; margin-left:100px; ">$pr</div>
</div>
HB1

        return ( $hb );
}

sub chpw {

	my $self = shift;
	my $hb=<<HB;
<div style="font-size :large;"><b>Change Password</b></div>
<div style="font-size :medium; margin-top:10px;">
<pre><span><b>current</b></span><span>    <input type="password" id="passw" name="passw"/></span></pre>
<pre><span><b>new</b></span><span>        <input type="password" id="npw1"/></span></pre>
<pre><span><b>retype</b></span><span>     <input type="password" id="npw2"/></span></pre>
</div>
<input class="butt1 dbord mlink_0" style="margin-top:10px;" type="button" onclick="ckpass([ 'passw', 'npw1', 'npw2'], ['resx']);" value="change"/>
<div id="resx"></div>
HB
	return ( $hb );
}

sub reguf {

	my $self = shift;
	my ( $text, $imgsrc, $dir ) = @_;
        my $hb;
	if (!$text && !$imgsrc && !$dir) {
		$hb =<<HB1;
<table>
<tbody id="all">
<tr><td>
<div style="font-size : large;">
<pre><img src="/tds/img/lepre_logo.png" style="width:100px; height:100px;"/></pre>
<pre><span><b>Name</b></span><span>               <input class="tba bg_tb2" type="text" id="name" name="name"/></span></pre>
<pre><span><b>Surname</b></span><span>            <input class="tba bg_tb2" type="text bg_tb1" id="surname" name="surname"/></span></pre>
<pre><span><b>Email</b></span><span>              <input class="tba bg_tb2" type="text" id="email" name="email"/></span></pre>
<pre><span><b>Username</b></span><span>           <input class="tba bg_tb2" type="text" id="username" name="username"/></span></pre>
<pre><span><b>Password</b></span><span>           <input class="tba bg_tb2" type="password" id="pwd" name="pwd"/></span></pre>
</div>
</td><td>
HB1
	}
	if ($text && $imgsrc && $dir) {
		$hb .=<<HB1;
<input type="hidden" id="bok" name="bok" value="$text"/>
<input type="hidden" id="ddel" name="ddel" value="$imgsrc"/>
<div style="margin-left:15px;"><img style="width:100px; height:80px; border-color: black; border-width: 5px; border-style:solid;" src=\"/tds/img/$imgsrc\.gif\">
<div style="font-size :medium; margin-top:10px;"><b>Are you human ?????? insert the word to confirm registration</b></div>
<div><input type="text" id="imgv" name="imgv" /></div>
<input class="butt1 dbord mlink_0" type="submit" id="act" value="Confirm" />
HB1
	}
	if (!$text && !$imgsrc && !$dir) {
		$hb .=<<HB1;
<div style="margin-top:10px;"><span id=\"tres\"></span>
<input class="butt1 dbord mlink_0" type="submit" id="ok" value="create account" />
</div>
</div>
<div id="resu" style="font-size : large;"></div>
</td></tr>
</tbody>
</table>
HB1
	}
	return ( $hb );
}

sub regu {

	my $self = shift;
	my ( $username ) = @_;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $uprosq = $nwuser->edup($username);
        my $uprorq = $dbc->sqlstate($dbpg, $uprosq, "far");
	my @uprors = @$uprorq;
	my $hb=<<HB1;
<table class="tnews">
  <tbody>
    <tr>
      <td>Name </td><td><INPUT type="text" name="name" id="name" </td><td><b>$uprors[0]<b></td>
    </tr>
    <tr>
      <td>Surname </td><td><INPUT type="text" name="surname" id="surname"></td><td><b>$uprors[1]</b></td>
    </tr>
    <tr>
      <td>Photo </td><td><iframe src="/tellyou/files.pl?$username&profile" height="70" frameborder="0"> </iframe></td>
    </tr>
    <tr>
      <td>gender </td><td><INPUT type="text" name="gender" id="gender"></td><td><b>$uprors[2]</b></td>
    </tr>
    <tr>
      <td>birthday </td><td><INPUT type="text" name="birth" id="birth"></td><td><b>$uprors[3]</b></td>
    </tr>
    <tr>
      <td>location </td><td><INPUT type="text" name="location" id="location"></td><td><b>$uprors[4]</b></td>
    </tr>
    <tr>
      <td>country </td><td><INPUT type="text" name="country" id="country"></td><td><b>$uprors[5]</b></td>
    </tr>
    <tr>
      <td>email </td><td><INPUT type="text" name="email" id="email"></td><td><b>$uprors[6]</b></td>
    </tr>
    <tr>
      <td>alias </td><td><INPUT type="text" name="alias" id="alias"></td><td><b>$uprors[7]</b></td>
    </tr>
    <tr>
      <td>Note </td><td><textarea cols="30" rows="3" name="note" id="note"></textarea></td><td><b>$uprors[8]</b></td>
    </tr>
   <tr>
      <td><td><input type="button" value="change" onclick="updp([ 'name', 'surname', 'gender', 'birth', 'location', 'country', 'email', 'alias', 'note', 'NO_CACHE' ], ['resu']);"/></td><td></td><td></td>
    </tr>
   <tr>
    <td><div id="resupr"></div></td>
   </tr>
  </tbody>
</table>
HB1

	return ( $hb );
}

sub hyon {

	my $self = shift;
	my ( $funcajax ) = @_;
	my $hb=<<HB1;
	<span class="lbutton mlink dbord" id="yes" onclick="$funcajax" >yes</span><span> </span><span class="lbutton mlink" id="no">no</span>
HB1
	return $hb;

}

sub regne {

	my $self = shift;
	my ( $username ) = @_;
	my $unw = rnews->new;
	my $idnas = $unw->idcone();
        my $hb=<<HB1;
<table class="tnews" >
<tbody>
    <tr>
      <td width="25%" >Location : </td><td width="75%" ><INPUT size="50" type="text" name="loca" id="loca"></td>
    </tr>
    <tr>
      <td>Head 1 : </td><td><INPUT size="50" type="text" name="head01" id="head01"></td>
    </tr>
    <tr>
      <td>Title : </td><td><INPUT size="50" type="text" name="title" id="title"></td>
    </tr>
    <tr>
      <td>link : </td><td><INPUT size="50" type="text" name="link" id="link"></td>
    </tr>
    <tr>
      <td>Head 2 : </td><td><INPUT size="50" type="text" name="head02" id="head02"></td>
    </tr>
    <tr>
      <td>Media : </td><td><iframe src="/tellyou/files.pl?$username&news&$idnas" height="70" frameborder="0"> </iframe><input type="hidden" id="media" value="$idnas" /></td>
    </tr>
    <tr>
      <td>News : </td><td><textarea cols="50" rows="20" id="irnews" name="irnews" rows="10" cols="20"></textarea></td>
    </tr>
    <tr>
      <td>Author : </td><td><INPUT size="50" type="text" name="nsauthor" id="nsauthor"></td>
    </tr>
    <tr>
      <td></td><td><input type="submit" value="insert" onclick="rn([ 'loca', 'head01', 'title', 'link', 'head02', 'media', 'irnews', 'nsauthor', 'NO_CACHE'  ], [ 'result' ]);"></td>
    </tr>
    <tr>
      <td></td><td><div id="result"></div></td>
    </tr>
</tbody>
</table>
HB1
      #<td></td><td><div onclick="rn([ 'title', 'irnews' ], [ 'resu' ]);">Insert News</div></td>
      #<td></td><td><form method="post" action="/tellyou/homenews.pl" enctype="application/x-www-form-urlencoded"><input type="submit" value="insert" onclick="rn([ 'head01', 'title', 'head02', 'media', 'irnews', 'nsauthor' ], [ 'resu' ]);"></form></td>

        return ( $hb );

}


sub editne {

        my $self = shift;
        my ( $username, $inas ) = @_;
        my $unw = rnews->new;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
        my $vnesq = $nwuser->vnews($username, $inas);
        my $vnerq = $dbc->sqlstate($dbpg, $vnesq, "far");
        my @vnewlq = @$vnerq;
        my $hb=<<HB1;
<table class="tnews" >
<tbody>
    <tr>
      <td width="10%" >Location : </td><td><INPUT width="30%" size="50" type="text" name="loca" id="loca"></td><td width="60%" ><span>$vnewlq[0]</span></td>
    </tr>
    <tr>
      <td>Head 1 : </td><td><INPUT size="50" type="text" name="head01" id="head01"></td><td><span>$vnewlq[1]</span></td>
    </tr>
    <tr>
      <td>Title : </td><td><INPUT size="50" type="text" name="title" id="title"></td><td><span>$vnewlq[2]</span></td>
    </tr>
    <tr>
      <td>link : </td><td><INPUT size="50" type="text" name="link" id="link"></td><td><span></span></td>
    </tr>
    <tr>
      <td>Head 2 : </td><td><INPUT size="50" type="text" name="head02" id="head02"></td><td><span>$vnewlq[3]</span></td>
    </tr>
    <tr>
      <td>Media : </td><td><iframe src="/tellyou/files.pl?$username&news&$vnewlq[4]" height="70" frameborder="0"> </iframe><input type="hidden" id="media" value="$vnewlq[4]" /></td><td></td>
    </tr>
    <tr>
      <td>News : </td><td><textarea cols="50" rows="20" id="irnews" name="irnews" rows="10" cols="20"></textarea></td><td><div><input type="hidden" id="timdat" value="$vnewlq[6]" />$vnewlq[5]</div></td>
    </tr>
    <tr>
      <td>Author : </td><td><INPUT size="50" type="text" name="nsauthor" id="nsauthor"></td><td><span>$vnewlq[7]</span></td>
    </tr>
    <tr>
      <td><input type="hidden" id="stat" value="update" /></td><td><input type="submit" value="save" onclick="rn([ 'loca', 'head01', 'title', 'link', 'head02', 'media', 'irnews', 'nsauthor', 'timdat', 'uinas', 'stat', 'NO_CACHE'  ], [ 'resu' ]);"></td><td></td>
    </tr>
    <tr>
      <td></td><td><div id="result"></div></td><td><input type="hidden" id="uinas" value="$inas" /></td>
    </tr>
</tbody>
</table>
HB1
      #<td></td><td><div onclick="rn([ 'title', 'irnews' ], [ 'resu' ]);">Insert News</div></td>
      #<td></td><td><form method="post" action="/tellyou/homenews.pl" enctype="application/x-www-form-urlencoded"><input type="submit" value="insert" onclick="rn([ 'head01', 'title', 'head02', 'media', 'irnews', 'nsauthor' ], [ 'resu' ]);"></form></td>

        return ( $hb );

}

sub activ {

	my $self = shift;
	my ( $username, $dlmt, $ofst, $nxt ) = @_;
	if (!$ofst) {
		$dlmt = 5;
		$ofst = 0;
	}
	my ($hb, $hb2, $inas, $fuse, $hbf, $hbn, $hbc, $vucard) = undef;
	my $unw = rnews->new;
	my $photop = $unw->getufil($username, 'profile');
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $vieactq = $nwuser->vieact( $username, $dlmt, $ofst, $nxt );
	my $vieactg = $dbc->sqlstate($dbpg, $vieactq, "far");
	my $userlog = genhtml->getloged();
	if ($userlog && $nxt ne 'ext') {
		$hbf =<<HB1;
    <div style="font-size:large;" id="ckto"></div><input type="hidden" id="tos" value="noset"/>
    <div style="margin-bottom:15px;"><textarea  id="newsact" cols="61" rows="4" onkeypress="if((document.getElementById('tos').value == 'noset') && (event.charCode == 32)) { ckse([ 'newsact', 'NO_CACHE'  ], [ 'ckto', 'tos' ]) }; var c=document.getElementById('newsact').value; document.getElementById('count').innerHTML = 500 - c.length ; "></textarea><span style="margin-left:20px; font-size:large; color:gray;" id="count" >500</span> 
    <div>
    <input  type="submit" class="mlink_0 dbord butt" value="Insert" onclick="var c=document.getElementById('newsact').value; if (c.length < 500) {iact([ 'newsact', 'NO_CACHE'  ], [ 'resu' ], 'POST');} else { document.getElementById('count').innerHTML = 'You can write max 250 characters ..... ';}"/>
    </div>
</div>
HB1
		$hbn =<<HB1;
<div><textarea class="bg_tb0" id="newsact" cols="61" rows="3" ></textarea>
<input class="bg_tb2 mlink_0" type="submit" value="insert" onclick="iact([ 'newsact', 'fusername', 'NO_CACHE'  ], [ 'resu' ]);"/>
</div>
HB1
	}
	if ($nxt eq "fol") {
		$vieactq = $nwuser->vieact( $username, $dlmt, $ofst, $nxt );
        	$vieactg = $dbc->sqlstate($dbpg, $vieactq, "far");
	}
	if (!$nxt && $nxt ne "fol") {
        	$hb = "<input type=\"hidden\" id=\"fusername\" value=\"$username\"/>" . $hbf;
        }
	if ($nxt eq "fol" && $ofst eq "0") {
		my $fwsq = $nwuser->fwait( $userlog, $username );
		my $fwsg = $dbc->sqlstate($dbpg, $fwsq, "f");
		if ($fwsg) { 
			$vucard = genhtml->ucard($username, "a"); 
        		$hb = "<input type=\"hidden\" id=\"fusername\" value=\"$username\"/>" . $vucard;
		} else {
			$vucard = genhtml->ucard($username, "1"); 
			$hb = "<input type=\"hidden\" id=\"fusername\" value=\"$username\"/>" . $vucard;
		}
        }
	if ($vieactg) {
        #my @iditem = @$vieactg;
        my @iditem = @$vieactg;
	my $nraf = $#iditem;
        my $fraf = $#iditem + 1;
        my $draf = $fraf / 5;
        my $i = 0 ;
        my $y = 0 ;
	my $a;
	my ($fphoto, $html_n, $html_f, $hla);
	$hb2 = "<input type=\"hidden\" id=\"fo\" value=\"f\"/>";
        foreach ($i=0; $i<$draf; $i++) {
		$fuse = $iditem[$y];
		$fphoto = undef;
		$html_f = '';
		if ($fuse) {
			if ($fuse eq $userlog && $nxt ne 'ext') {
                        	$html_f = "<img src=\"/tds/img/bar_butt.png\" />";
                	}
			$fphoto = $unw->getufil($fuse, 'profile', 'a');
			$fuse .= "\ \:";
		} else {
			$fuse = undef;
		}
		$y += 1;
		my $nuse = $iditem[$y];
		$html_n = '';
		if ($nuse eq $userlog && $nxt ne 'ext') {
			$html_n = "<img src=\"/tds/img/bar_butt.png\"/>";
		} 
		my $nphoto = $unw->getufil($nuse, 'profile', 'a');
		$hb2 .= "<div class=\"coms\" style=\"width:600px;\" >$nphoto";
                $y += 1;
		$hb2 .= "<input type=\"hidden\" id=\"$iditem[$y]\" value=\"$iditem[$y]\"/>";
		my $inas = $iditem[$y];
		my $liksq = $nwuser->vlik($username, $inas, "activity" );
        	my $liksg = $dbc->sqlstate($dbpg, $liksq, "f");
		my $cosq = $nwuser->cocom($username, 'comment', "$inas");
                my $cogq = $dbc->sqlstate($dbpg, $cosq, "f");
		$y += 1;
                $hb2 .=<<HB;
<sub>$nuse $iditem[$y]</sub><span class="mlink_0" onclick=\"delit([\'$inas\'], ['resu']);\"> $html_n</span>
HB
                $y += 1;
		if ($y == 4) { 
			$hla = "<a style=\"font-size:large; text-indent:20px; margin-left:5px; margin-right:10px; overflow:hidden;\">$iditem[$y]</a>";
		} else {
			$hla = "$iditem[$y]";
		}
                $hb2 .= "<p style=\"text-indent:20px; margin-left:5px; margin-right:10px;\"><b>$hla</b></p><span class=\"mlink_0\" onclick=\"delit([\'$inas\', \'fo\', \'NO_CACHE\' ], ['resu']);\">$html_f</span></div>";
                $y += 1;
		if ($userlog && $nxt ne 'ext') {
			$hbc =<<HB1;
        <div style="border-color: #E6FFC2; border-width: 1px; border-style:solid;"><input type=\"hidden\" id="tabcom$y" value="activity"/><!--span  class="mlink_0" id="comme$y" onclick="vcom([\'$inas\', 'rcom$y$ofst', 'NO_CACHE' ], ['hcom$y$ofst'])" >comments($cogq) </span><input type="submit" value="like: $liksg" onclick="inlik([\'$inas\', 'tabcom$y'], ['relik$y'])"><img class="imglk" onclick="inlik([ \'$inas\', \'tabcom$y\', 'NO_CACHE' ], ['relik$y']);" src="/tds/img/like.png" width="18" height="20"/><span id="relik$y">$liksg</span></div-->
	<input type="hidden" id="rcom$y$ofst" value="hcom$y$ofst" />
	<div id="hcom$y$ofst"></div>
HB1
		}
		$hb2 .= $hbc;
	}
	if ($ofst ne "0") {
      		$hb .= $hb2 ;
	} else {
      		#$hb .=  "<tr><td>" . $hb2 ;
      		$hb .=  "" . $hb2 ;
	}
	 if ($nxt eq "n" || !$nxt) {
      $hb .=<<HB1
	<input type="hidden" id="$ofst" value="$ofst" /><input type="hidden" id="$dlmt" value="5" /><input type="hidden" id="next" value="n" />
		<div id="nact$ofst"></div><div id="_$ofst" class="ttext"><input type="button" class="mlink_0 dbord butt" value="Next" onclick="acti([ 'fusername', '$dlmt', '$ofst', 'next', 'NO_CACHE'  ], [ 'nact$ofst', '_$ofst' ]);"></div>
HB1
	}
	if ($nxt eq "fol") {
		$ofst += 5;
		$hb .=<<HB1
        <input type="hidden" id="$ofst" value="$ofst" /><input type="hidden" id="$dlmt" value="5" /><input type="hidden" id="next" value="fol" />
                <div id="nact$ofst"></div><div id="_$ofst" class="ttext"><input type="button" class="mlink_0 dbord butt" value="Next" onclick="acti([ 'fusername', '$dlmt', '$ofst', 'next', 'NO_CACHE'  ], [ 'nact$ofst', '_$ofst' ]);"/></div>
HB1
	}
	}
	$dbc->dbx($dbpg);
	return ( $hb );

}


sub icom {

	my $self = shift;
        my ( $username, $inas, $rcom ) = @_;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $unw = rnews->new;
        my $cosq = $nwuser->vcomm($username, $inas);
        my $cogq = $dbc->sqlstate($dbpg, $cosq, "far");
        my @lstq = @$cogq;
	my $nraf = $#lstq;
        my $fraf = $#lstq + 1;
        my $draf = $fraf / 2;
        my $i = 0 ;
        my $y = 0 ;
	my ($ehdiv, $hdiv) = undef;
	foreach ($i=0; $i<$draf; $i++) {
		my $cphoto = $unw->getufil($lstq[$y], 'profile', 'a');
		$hdiv .= "<p>$cphoto <b>$lstq[$y] :</b>";
		$y += 1;
		$hdiv .= "$lstq[$y]</p><br/>"; 
		$y += 1;
	}
	my $hb = "<div class=\"ident lcom\">$hdiv</div>";
	$hb .=<<HB1;
          <input type="hidden" id="taci" value="activity"/><input type="hidden" id="$inas" value="$inas"/><input type="hidden" id="r$rcom" value="$rcom"/><textarea cols="50" rows="2" id="chcom$rcom"></textarea>
          <input type="submit" value="insert" onclick="insco(['taci', 'chcom$rcom', '$inas', 'r$rcom', 'NO_CACHE' ], [\'$rcom\'])">
HB1

        return ( $hb );

}

sub ucard {
	
	my $self = shift;
	my ( $username, $fixd ) = @_;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $ucsq = $nwuser->usercard($username);
        my $ucgq = $dbc->sqlstate($dbpg, $ucsq, "far");
	my @items = @$ucgq;
	my $nraf = $#items;
	my $fraf = $#items + 1;
        my $draf = $fraf / 5;
	my $i = 0 ;
        my $y = 0 ;
        my $hb = undef;
	foreach ($i=0; $i<$draf; $i++) {
		$hb .= "<b> $items[$y]";
		$y += 1;
		$hb .= " $items[$y] </b>";
		$y += 1;
		$hb .= "$items[$y]<br/>";
                $y += 1;
		$hb .= "$items[$y]<br/>";
                $y += 1;
		$hb .= "<!--div class=\"vtext\"> $items[$y]</div-->";
                $y += 1;
		if ($fixd eq "1" ) {
			$hb .= "<input type=\"hidden\" id=\"$username\" value=\"$username\"/>";
			$hb .= "<span id=\"badd$username\" onclick=\"infol([ \'$username\'], [\'badd$username\', \'NO_CACHE\' ]);\" class=\"lbutton mlink\"><b>Follow</b></span>";
		} 
		if ($fixd eq "a" ) {
			$hb .= "<input type=\"hidden\" id=\"$username\" value=\"$username\"/>";
			$hb .= "<span id=\"badd$username\" >Following</span>";
		}
		if ($fixd eq "w" ) {
			$hb .= "<span id=\"badd$username\" >wait .... </span>";
		}
		if ($fixd eq "e" ) {
                        $hb .= "<span style=\"margin-top:30px; border-top-color: black; border-top-width: 1px; border-top-style:solid;\" id=\"edip\" class=\"vtext mlink\" onclick=\"edp(['username', \'NO_CACHE\'], ['resu']);\">Edit Profile</span>";
                }
			
	}
	return ($hb);

}

sub vmess {

	my $self = shift;
	my ( $username, $modal, $inas ) = @_;
	my ( $vmsgsq, $vmsgrq, @raf, $nraf, $fraf, $draf, $hb ) = undef;
        my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	if ($modal eq "r") {
		$vmsgsq = $nwuser->vusmess($username, $modal, $inas);
		$vmsgrq = $dbc->sqlstate($dbpg, $vmsgsq, "far");
		@raf = @$vmsgrq;
		$nraf = $#raf;
        	$fraf = $#raf + 1;
        	$draf = $fraf / 4;
		my $i = 0 ;
		my $y = 0 ;
		foreach ($i=0; $i<$draf; $i++) {
			$hb .="<div>\@$raf[$y]</div>";
                	$y +=1;
                	$hb .="<div style=\"border-color: green; border-width: 1px; border-style:solid;\"><b>$raf[$y]</b></div>";
                	$y +=1;
                	$hb .="<div style=\"border-color: green; border-width: 1px; border-style:solid;\">$raf[$y]</div>";
                	$y +=1;
                	$hb .="<div>$raf[$y]</div>";
                	$y +=1;
		}
	} else {
		$vmsgsq = $nwuser->vusmess($username);
		$vmsgrq = $dbc->sqlstate($dbpg, $vmsgsq, "far");
		@raf = @$vmsgrq;
		$nraf = $#raf;
                $fraf = $#raf + 1;
       	        $draf = $fraf / 5;
		my $i = 0 ;
        	my $y = 0 ;
        	$hb = undef;
	$hb =<<HB;
<input type="hidden" id="tos" value="noset"/>
<div style="height:40px;"><b><a id="ckto"></a></b></div><textarea  id="wmsg" cols="61" rows="4" onkeypress="if((document.getElementById('tos').value == 'noset') && (event.charCode == 32)) { ckse([ 'wmsg', 'NO_CACHE'  ], [ 'ckto', 'tos' ]) };"></textarea>
<input  type="submit" class="mlink_0 dbord butt" value="Send" onclick="wrm(['wmsg'],['ckto','wmsg']);" />
HB
		#$hb .="<div><span style=\"margin-left:30px;\">From</span><span style=\"margin-left:30px;\">Subject</span><span style=\"margin-left:30px;\">Received</span></div>";
		foreach ($i=0; $i<$draf; $i++) {
			$hb .="<input type=\"hidden\" id=\"$raf[$y]\" value=\"$raf[$y]\" />";
			my $idnas = $raf[$y];
			$y +=1;
			$hb .="<dl><dd><span style=\"margin-left:30px;\"><b>\@$raf[$y]</b></span></dd>";
			$y +=1;
                	$hb .="<dd><span style=\"margin-left:30px;\" class=\"mlink_0\" onclick=\"mesg([ \'r\', \'$idnas\', \'NO_CACHE\' ], [ \'resu\' ]);\"><input type=\"hidden\" id=\"r\" value=\"r\" />$raf[$y]</span></dd>";
                	$y +=1;
                	$hb .="<dd><span style=\"margin-left:30px; border-top-color: black; border-top-width: 1px; border-top-style:solid;\">$raf[$y]</span></dd></dl>";
                	$y +=1;
			my $mread = $raf[$y];
                	$y +=1;
		}
	}
	return ($self, $hb);

}


sub hlnews {

	my $self = shift;
        my ( $lsnews, $username ) = @_;
	my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
	my $nwuser = user->new;
        my @raf = @$lsnews;
        my $nraf = $#raf;
        my $fraf = $#raf + 1;
        my $draf = $fraf / 4;
	my $i = 0 ;
        my $y = 0 ;
        my $hb = undef;
#<<HB1;
#<table width="500" >
#  <tbody>
#HB1

#onclick=\"fpg2([\'username\', \'$idt\'], [\'inf\']);\"

        foreach ($i=0; $i<$draf; $i++) {
                my $idt = $raf[$y];
                $y +=1;
                my $damtim = $raf[$y];
                $y +=1;
                my $tito = $raf[$y];
                $y +=1;
                my $noti = $raf[$y];
                $noti = substr($noti, 0, 150);
                $y +=1;
		my $cosq = $nwuser->cocom($username, 'comment', "$idt");
                my $cogq = $dbc->sqlstate($dbpg, $cosq, "f");
		my $vlisq = $nwuser->vlik($username, "$idt");
		my $vligq = $dbc->sqlstate($dbpg, $vlisq, "f");
		my $funcajax = "dlnw([ \'$idt\'], [\'resu\']);";
                #$hb .= "<tr class=\"coms\"><td class=\"htd01\"><input type=\'hidden\' id=\'$idt\' value=\'$idt\'><input type=\'hidden\' id=\'a$y\' value=\"$funcajax\"><div>$damtim</div></td><td id=\'$tito\'><b>$tito</b></td><td><span class=\"lbutton mlink dbord\" onclick=\"son([\'a$y\'], ['choose$y']);\">delete</span></td><td><div id=\'choose$y\'></div><span class=\"lbutton mlink dbord\" onclick=\"edn([\'$idt\'], ['resu']);\">edit</span></td></tr><tr ><td class=\"htd01\" colspan=\'4\'>$noti ... comments ($cogq) - like ($vligq)</td></tr><tr ><td colspan=\'4\'><br/></td></tr>\n";
        	$hb .=<<HB1;
<input type="hidden" id="$idt" value="$idt">
<input type="hidden" id="a$y" value="$funcajax">
<p>$damtim <b>$tito</b>
<span class="lbutton mlink dbord" onclick="son([\'a$y\'], ['choose$y']);">delete </span><span id='choose$y'></span><span class="lbutton mlink dbord" onclick="edn([ \'$idt\', \'NO_CACHE\' ], ['resu']);">edit</span></p>
<div>$noti ... comments ($cogq) - like ($vligq)</div>
HB1
}
#        $hb .= "";
#</tbody>
#</table>
#HB1
        return ( $hb );



}

sub listnws {

	my $self = shift;
	my ( $lsnews ) = @_;
	my @raf = @$lsnews;
	my $nraf = $#raf;
	my $fraf = $#raf + 1;
	my $draf = $fraf / 4;
	my $i = 0 ;
	my $y = 0 ;
	my ( $a, $b, $c, $d, $e ) = 0;
	my $hb=<<HB1;
<table width="600" >
  <tbody>
    <tr >
	<td class="lst"></td><td class="lst"><b>Created</b></td><td class="lst"><b>Title</b></td><td class="lst"><b>News</b></td>
    </tr>
HB1
	foreach ($i=0; $i<$draf; $i++) {
		$a = 10000 + $i;
		my $idt = $raf[$y];
                $y +=1;
		$b = 20000 + $i;
		my $damtim = $raf[$y];
		$y +=1;
		$c = 30000 + $i;
		my $tito = $raf[$y];
		$y +=1;
		$d = 40000 + $i;
		my $noti = $raf[$y];
		$noti = substr($noti, 0, 50);
		$y +=1;
		$e = 50000 + $i;
		$hb .= "<tr id=\'a$idt\' ><td class=\'lst\'><input type=\'hidden\' id=\'$idt\' value=\'$idt\'></td><td class=\'lst\'><div>$damtim</div></td><td id=\'$tito\' class=\'lst\'>$tito</td><td class=\'lst\'>$noti</td>\n";
		$hb .=<<HB1;
   <input type='hidden' id='lst'>
   <td name="a$i" id="$a" class="tcell" >
     <div onclick="setcolor('cc01','tc01','$idt','a$i','$a','$draf');" onmouseover="chancolor('cc01','cc01');" onmouseout="flashcolor('cc01','cc01');"><SPAN  style="visibility : hidden;">O</SPAN></div>
   </td>
   <td name="a$i" id="$b" class="tcell" >
     <div onclick="setcolor('ll01','tl01','$idt','a$i','$b','$draf');" onmouseover="chancolor('ll01','ll01');" onmouseout="flashcolor('ll01','ll01');"><SPAN  style="visibility : hidden;">O</SPAN></div>
   </td>
   <td name="a$i" id="$c" class="tcell" >
     <div onclick="setcolor('cc02','tc02','$idt','a$i','$c','$draf');" onmouseover="chancolor('cc02','cc02');" onmouseout="flashcolor('cc02','cc02');"><SPAN  style="visibility : hidden;">O</SPAN></div>
   </td>
   <td name="a$i" id="$d" class="tcell" >
     <div onclick="setcolor('ll02','tl02','$idt','a$i','$d','$draf');" onmouseover="chancolor('ll02','ll02');" onmouseout="flashcolor('ll02','ll02');"><SPAN  style="visibility : hidden;">O</SPAN></div>
   </td>
   <td name="a$i" id="$e" class="tcell" >
     <div onclick="setcolor('dd01','td01','$idt','a$i','$e','$draf');" onmouseover="chancolor('dd01','dd01');" onmouseout="flashcolor('dd01','dd01');"><SPAN  style="visibility : hidden;">O</SPAN></div>
   </td>
 </tr>
HB1
	}
	$hb .=<<HB1;
</tbody>
</table>
HB1
	return ( $hb );

}

sub mfpage {

	my $self = shift;
        my ( $username ) = @_;
	my $hb=<<HB1;
<table class="tmpg"  cellpadding="1" cellspacing="0"> 
  <tbody>
    <tr>
      <td colspan="3" height="10%" align="center" class="tcell"><input type="hidden" id="hh01" value="think.do.share">think.do.share</td>
    </tr>
    <tr>
      <td colspan="2" id="cc01" height="22%" class="tcell"><input type="hidden" id="tc01">CENTER</td>
      <td id="mm01" class="tcell">Media1</td>
    </tr>
    <tr>
      <td id="ll01" class="tcell"><input type="hidden" id="tl01" class="tcell">Left1</td>
      <td id="cc02" height="22%" class="tcell"><input type="hidden" id="tc02">Center2</td>
      <td id="mm02" class="tcell">Media2</td>
    </tr>
    <tr>
      <td id="ll02" class="tcell"><input type="hidden" id="tl02">Left2</td>
      <td id="dd01" class="tcell"><input type="hidden" id="td01">DOWN</td>
      <td id="mm03" height="22%" class="tcell">Media3</td>
    </tr>
    <tr>
      <td>
      <input type="submit" value="compose" onclick="fpg([ 'hh01', 'tc01', 'tl01', 'tl02', 'tc02', 'td01', 'NO_CACHE'  ], [ 'inf' ]);">
      </td>
      <td>
      <input type="submit" value="view" onclick="">
      </td>
      <td>
      </td>
  </tbody>
</table>
HB1
	return ( $hb );
}


sub viewnws {

	my $self = shift;
        my ( $username, $inas, $tdcreted ) = @_;
        my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $unw = rnews->new;
	my $liksq = $nwuser->vlik($username, $inas );
	my $liksg = $dbc->sqlstate($dbpg, $liksq, "f");
	my $vnsq = $nwuser->vnews($username, $inas );
	my $vngq = $dbc->sqlstate($dbpg, $vnsq, "far");
	my $cosq = $nwuser->cocom($username, 'comment', "$inas");
        my $cogq = $dbc->sqlstate($dbpg, $cosq, "f");
	my @lstq = @$vngq;
	my $photop = $unw->getufil($username, 'news', '', $lstq[4]);
	my $hb=<<HB1;
<table>
  <tbody>
    <tr>
      <input type="hidden" id="vinas" value="$inas"/>
      <td class="tdu2" ><SPAN title="location">$lstq[0] - $lstq[6]</SPAN></td>
    </tr>
    <tr>
      <td><h4>$lstq[1]</h4></td>
    </tr>
    <tr>
      <td><h1 id="titoh1" >$lstq[2]</h1></td>
    </tr>
    <tr>
      <td><h3>$lstq[3]</h3></td>
    </tr>
    <tr>
      <td><div>$photop</div><SPAN title="$lstq[2]">$lstq[5]</SPAN></td>
    </tr>
    <tr>
      <td class=\"tdu2\">
      <input type="hidden" id="tabnews" value="news"/>
      <!-- input type="submit" value="like" onclick="inlik(['vinas', 'tabnews', 'NO_CACHE' ], ['relik'])">
      <span id="relik">$liksg</span --!>
      </td>
    </tr>
    <tr>
	<td><span id="comme" class="linkst mlink" onclick="vcom(['vinas', 'NO_CACHE' ], ['hcom'])" >comments($cogq)</span><span>$lstq[7]</span></td>
    </tr>
    <tr>
	<td id="hcom"></td>
    </tr>
  </tbody>
</table>
HB1
        return ( $hb );

}

sub  listans {

	my $self = shift;
        my ( $username ) = @_;
        my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
        my $vasq = $nwuser->alunws($username);
        my $vagq = $dbc->sqlstate($dbpg, $vasq, "far");
        my @lstq = @$vagq;
	my $nr = $#lstq;
        my $fr = $#lstq + 1;
        my $dr = $fr / 4;
	my $i = 0 ;
        my $y = 0 ;
	my $hb=<<HB1;
<input type="hidden" id='username' value="$username"/>
<!--table class="tu1" --!>
  <!--tbody--!>
  <!--tr><td><div id="fnew"></div></td></tr--!>
   <div id="fnew"></div>
HB1
	foreach ($i=0; $i<$dr; $i++) {

		$hb .= "<input type=\"hidden\" id=\"inas$i\" value=\"$lstq[$y]\"/>";
		my $idnas = $lstq[$y];
		$y +=1;
		#$hb .= "<tr><td class=\"tdu2\" ><div class=\"linkst mlink\"><h1 id=\"$y\" onclick=\"vie(['inas$i'], ['fnew'])\" >$lstq[$y]</h1></div></td></tr>";
		$hb .= "<div class=\"tdu2\" ><div class=\"linkst mlink\"><h1 id=\"$y\" onclick=\"vie(['inas$i', 'NO_CACHE' ], ['fnew'])\" >$lstq[$y]</h1></div></div>";
		my $cosq = $nwuser->cocom($username, 'comment', "$idnas");
		my $cogq = $dbc->sqlstate($dbpg, $cosq, "f");
		$y +=1;
		#$hb .= "<tr><td><span>$lstq[$y]</span>";
		$hb .= "<span>$lstq[$y]</span>";
                $y +=1;
		$lstq[$y] = substr($lstq[$y], 0, 150);
		#$hb .= "<span>$lstq[$y] .....</span></td></tr>";
		$hb .= "<span>$lstq[$y] .....</span>";
                $y +=1;
		#$hb .= "<tr><td><div>($cogq) comments</div><br></td></tr>";
		$hb .= "<div>($cogq) comments</div><br>";
	}
#	$hb .=<<HB1;
#<!--/tbody>
#</table--!>
#HB1
        return ( $hb );
}

sub ufpage {

	my $self = shift;
        my ( $username ) = @_;
        my $dbc = conndb->new;
        my $dbpg = $dbc->dbuse();
        my $nwuser = user->new;
	my $fpsq = $nwuser->vieufpg($username);
	my $fpgq = $dbc->sqlstate($dbpg, $fpsq, "far");
	my @lstq = @$fpgq;
	my $i=0;
        my $hb=<<HB1;
<table>
  <tbody>
    <tr class="td001">
      <td id="titonews"><h1></h1></td><td><input type="hidden" id='username' value="$username"/></td>
    </tr>
    <tr><td ><div id="fnew">
HB1
	for ($i=0; $i<5; $i++) {
		$hb .= "<div class=\"tdu1\">$lstq[$i]</div>";
	}
	$hb .=<<HB1;
</td></tr>
  </tbody>
</table>
<table>
  <tbody>
    <div id="all_news"></div>
    <div onclick="alns(['NO_CACHE' ], ['all_news']);">all news</div>
  </tbody>
</table>
HB1
        return ( $hb );
}




1;
