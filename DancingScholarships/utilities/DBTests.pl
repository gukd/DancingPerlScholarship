#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use DBI;


use Encode qw(encode_utf8);
open my $out, '>', "dbtest1.txt";


my $dbh = DBI -> connect ("DBI:SQLite:susitest.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr ;
#$dbh->do(q{INSERT INTO accounts VALUES ('georgiu' , 'abv', '80716')});
#$dbh->do(q{INSERT INTO userInfo VALUES ('80716' , 'georgi dimitrov urumov' , '5.30')});
my $susiRetrieveGrade = $dbh -> prepare(q{SELECT u.grade FROM userInfo u WHERE u.fn = :fn});



my $printbase = $dbh->prepare(q{SELECT * FROM accounts GROUP BY fn });
$printbase->execute();


sub getGrade
{
  my $fn = shift @_;
  $susiRetrieveGrade -> execute($fn);
  my @res = $susiRetrieveGrade -> fetchrow_array();
  if ( $res[0] =~ m/\d+.\d+/)
  {
     print "$res[0]";
  }
  else
  {
    print "0";
  }  
}

my $fn = 80716;

&getGrade($fn);


#while (my @res = $printbase->fetchrow_array) {
#    print {$out} encode_utf8 "@res\n";
#}

$dbh->disconnect();

#sub test
#{
#  my $f = shift;
#  
#}
#$ssh->execute();
#my $i = 1;
#while (my @res = $ssh->fetchrow_array) {
#    print "@res\n";
#   $sbh->execute($i, $res[0]);
#   $i++;
#}