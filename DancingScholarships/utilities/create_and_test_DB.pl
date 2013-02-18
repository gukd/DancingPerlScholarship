#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use utf8;

use open qw/:std :utf8/;

my $dbh = DBI -> connect ("DBI:SQLite:susitest.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr ;

#$dbh->do(q{CREATE TABLE accounts (username TEXT, password TEXT)});
#$dbh->do(q{INSERT INTO accounts VALUES ('georgi' , 'abv')});
#$dbh->do(q{INSERT INTO accounts VALUES ('kosta' , 'kdd')});
#$dbh->do(q{INSERT INTO accounts VALUES ('georgiu' , 'abv')});
#$dbh->do(q{INSERT INTO accounts VALUES ('kostad' , 'ьяа')});

 CONSTRAINT fk_userInfo Foreign KEY (fn) REFERENCES accounts (fn))});
#$dbh->do(q{ALTER TABLE accounts ADD FN Integer }); 
#$dbh->do(q{ALTER TABLE userInfo ADD FOREIGN KEY (fn) REFERENCES accounts (fn) });
#my $sbb = $dbh->prepare(q{SELECT a.username FROM accounts a});
#my $sbh = $dbh->prepare(q{UPDATE accounts SET FN = :fn WHERE username = :names});
my $ssh = $dbh->prepare(q{SELECT username, FN FROM accounts GROUP BY FN });

$ssh->execute();
#my $i = 1;
while (my @res = $ssh->fetchrow_array) {
    print "@res\n";
#   $sbh->execute($i, $res[0]);
#   $i++;
}

#$dbh->do(q{CREATE TABLE notes (FN Integer , Note Single, CONSTRAINT fk_notes Foreign KEY (FN) REFERENCES accounts (FN))});
#$dbh->do(q{CREATE TABLE Scholarships (FN Integer, NoteUser Single , NoteSusi Single, CONSTRAINT fk_scholarship Foreign Key (FN) REFERENCES accounts (FN))});

#my $sbh = $dbh->prepare(q{SELECT a.password FROM accounts a WHERE a.username = 'kostad'});
#$sbh->execute();

#while ( my @row = $ssh->fetchrow_array ) {
#    binmode(STDOUT, ":utf8");
#    print "@row\n";
#  }

$dbh -> disconnect();