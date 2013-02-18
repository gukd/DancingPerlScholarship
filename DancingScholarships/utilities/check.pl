#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use DBI;

#binmode(STDOUT, ":utf8");

#SUSI TESTING

my $susiDbh = DBI -> connect ("DBI:SQLite:susitest.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr;
my $susiUserCheck = $susiDbh -> prepare("SELECT a.password FROM accounts a WHERE a.username = :name ");
my $susiUserInsert = $susiDbh -> prepare("INSERT INTO accounts VALUES ( :name , :pass)");



#Scholarship DB testing

my $moneyDbh = DBI -> connect ("DBI:SQLite:money.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr;
my $moneyAddEntry = $moneyDbh -> prepare("INSERT INTO scholarships VALUES ( :FN , :GRD );

my $susi_username = $ARGV[0];
my $susi_password = $ARGV[1];


sub checkUser
{
   my ($uname,$pass) = @_;   
   $susiUserCheck->execute($uname);
   my @res = $susiUserCheck->fetchrow_array();
   if (scalar(@res) == 0 || ($res[0] ne $pass)) 
   {
     print "Incorect Username - $uname or password - $pass!";
     return 0; 
   }
   else
   {
     print "Correct! Logging user $uname ";
     return 1;   
   }
}


sub insertUser
{
   my ($uname,$pass) = @_; 
   $susiUserCheck->execute($uname);
   my @res = $susiUserCheck->fetchrow_array();
   if (scalar(@res) > 0)
   {
     print "The Selected user is already included in the DB!";
     $susiUserCheck->finish;
   }
   else
   {
     $susiDbh->begin_work;
     eval 
     {
       $susiUserInsert->execute($uname, $pass) or die "Couldn't access the DB! Rolling back!";
     };
     if($@) 
     {
       $susiUserInsert->finish;
       $susiDbh->rollback;
     }
     else
     {
       print "Added user $uname with password $pass !"; 
       $susiDbh->commit;
     }
   }
}

#checkUser($username, $password);
#insertUser($username, $password);


$dbh -> disconnect();