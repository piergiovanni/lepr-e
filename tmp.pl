#!/usr/bin/perl -w

use strict;
use CGI;
use Time::gmtime;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Digest::SHA qw(sha1 sha1_hex sha1_base64);

my $nas = `date "+%N"`;
my $ra = rand(9999);
#my $digest = sha1_base64($ARGV[0]);
#print $digest . "\n";
print $ra . $nas . "\n";
#print crypt($ra, $ARGV[0]) . "\n";

my $drs="oK \n pippo";
my $didi = "sampei";

#if ($ARGV[0] =~ /\\|\/|\'|\"|\^|\(|\)|\||\$|\.|è|é|à|ù|°|ò|ç|@|;|:|<|>|£|!|£|%|&|=|\{|\}/) {
if ($ARGV[0] =~ /\\|\'/) {
	$ARGV[0] =~ s/\\/\\\\/g;
	$ARGV[0] =~ s/\'/''/g;
	print $ARGV[0] . "\n";
	$drs = "insert an invalid char in username!!!";
}

sub cht {
	my ( $str ) = @_;
	foreach ( $str ) {
		$_ =~ s/i/I/g;
		return ( $str );
	}
}

$drs =~ s/\n//g;
print $drs . "\n";

my @ratest = ("uno", "due", "tre", "uno", "due", "tre", "uno", "due", "tre");
my $nratest = $#ratest;
my $fratest = $#ratest + 1;
my $dratest = $fratest / 3;
my $y = 0;
my $i = 0;

for ($i=0; $i<$dratest; $i++) {

	print "$i $y $ratest[$y] ";
	$y +=1;
	print "$y $ratest[$y] ";
	$y +=1;
	print "$y $ratest[$y]\n";
	$y +=1;

}

print "$#ratest $fratest $dratest\n";

foreach ($didi) {
$_ = &cht($didi);
}

print $didi . "\n"; 
my $st = "10000,abc,cvf";
my $dst = substr($st, index($st, ","));
$st =~ /^(.*?),/sgm;
print "$1 \n";


#my $hq = CGI->new;
#my $HTML = $hq->start_html(-script =>{-src=> "js/elabor.js"});
#print $HTML;


print $dst;



sub ola {

	my ( $a ) = @_;
	my $b = $a + 3;
	my $c = $b + 3;
	return ( $b, $c );

}

my ( $w, $z ) = &ola(3);
print $w . " " . $z . "\n";

my $now = gmctime();
my $lc = time;
print $now . "\n" . $lc;
print scalar localtime($lc);








