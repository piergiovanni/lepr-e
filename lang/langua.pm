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

package langua;


sub new {
    my $class = shift;
    return bless {}, $class;
}



sub welcome {

	my $self = shift;
	my ($lg) = @_;
	my $en_w = "Welcome to social network \"lepr-e\" , you can post yuor news, \n you can follow the activities the others users and to communicate with their. ";
	my $it_w = "Benvenuto nel social network \"lepr-e\", tu puoi fin da ora \n postare i tuoi contenuti , seguire le attività degli altri utenti e comunicare con loro.";
	if ($lg eq "en") {
		return ( $self, $en_w) 
	}
	if ($lg eq "it") {
		return ( $self, $it_w) 
	}

}

sub weHome {

	my $self = shift;
        my ($lg) = @_;
	my $en_wH = "\"lepr-e\" is a social networking where you can post your content , flash report , your activities and you can follow and communicate with others users.";
	my $it_wH = "\"lepr-e\" è un social network dove puoi pubblicare i tuoi contenuti, come notizie ,  attività, seguendo anche quelle di altri utenti della rete , puoi comunicare con loro creando la tua rete di contatti.";
	if ($lg eq "en") {
                return ( $self, $en_wH) 
        }
        if ($lg eq "it") {
                return ( $self, $it_wH)
        }

}

sub specPrj {

	my $self = shift;
        my ($lg) = @_;
        my $en_sPj = <<HB;
<ul>
<li>\"lepr-e\" is developed in perl and is a open project</il>
<li>This software is licensed under the Affero General Public License version 3</li>
<li>You can download source from github repository <a href="http://github.com/piergiovanni/lepr-e">lepr-e</a></li>
</ul> 
HB
	return($self,  $en_sPj);

}

sub tosL {

	my $self = shift;
        my ($lg) = @_;
        my $en_ts = <<HB;
lpr-e is a social networking open source released under agpl 3.0 license,  on this web site there is installed a beta version and only for purposes of development and testing.

lpr-e reserves the right to modify or stop the Service (or any part thereof), either temporarily or permanently, 
at any time or from time to time, with or without prior notice to you.

When you have activated your account, you agree these obligations : 

For any content posted, upload, download, transmit by you  as data files, written text, software, 
music, graphics, photographs, images, sounds, videos, messages and any other like materials, you are solely responsible.

For any problems you can send email to info\@lepr-e.com.
HB

	return($self,  $en_ts);

}




1;
