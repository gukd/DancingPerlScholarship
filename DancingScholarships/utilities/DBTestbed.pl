#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use DBI;


use open qw/:std :utf8/;

my $dbh = DBI -> connect ("DBI:SQLite:susitest.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr ;

#login table - username, pass, FN - PK

$dbh->do(q{CREATE TABLE accounts (username VARCHAR(50), password VARCHAR(50), fn VARCHAR(10) PRIMARY KEY)});
$dbh->do(q{INSERT INTO accounts VALUES ('pesho' , 'maniak', '99999')});
$dbh->do(q{INSERT INTO accounts VALUES ('kosta' , 'kdd','90000')});
$dbh->do(q{INSERT INTO accounts VALUES ('georgiu' , 'abv','80716')});
$dbh->do(q{INSERT INTO accounts VALUES ('ХанкуБрат' , 'хан','80000')});
$dbh->do(q{INSERT INTO accounts VALUES ('ivan' , 'ivan','70000')});

#susi user records table

$dbh->do(q{CREATE TABLE userInfo (fn VARCHAR(10) PRIMARY KEY , name VARCHAR(100), grade FLOAT, CONSTRAINT fk_userInfo Foreign KEY (fn) REFERENCES accounts (fn))});
$dbh->do(q{INSERT INTO userInfo VALUES ('99999' , 'pesho peshev' , '4.20')});
$dbh->do(q{INSERT INTO userInfo VALUES ('90000' , 'kosta dimitrov dimitrov' , '5.99')});
$dbh->do(q{INSERT INTO userInfo VALUES ('80716' , 'georgiu dimitrov urumov' , '5')});
$dbh->do(q{INSERT INTO userInfo VALUES ('80000' , 'Ханку Брат' , '4.78')});
$dbh->do(q{INSERT INTO userInfo VALUES ('70000' , 'Ivan dimitrov' , '5.67')});

#admin table

$dbh->do(q{CREATE TABLE admins (username VARCHAR(50) PRIMARY KEY , password VARCHAR(50))});
$dbh->do(q{INSERT INTO admins VALUES ('galeks' , 'sajalqvam')});
$dbh->do(q{INSERT INTO admins VALUES ('magda' , 'mranmran')});
$dbh->do(q{INSERT INTO admins VALUES ('minko' , 'kolega')});

$dbh -> disconnect();

#dbase for the scholarships

#my $ScholarDbh = DBI -> connect ("DBI:SQLite:scholarships.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr ;
#$ScholarDbh->do(q{CREATE TABLE studentInfo (fn VARCHAR(10) PRIMARY KEY , faculty VARCHAR(100), specialty VARCHAR(50), year VARCHAR(10), studyYear VARCHAR(1), semester VARCHAR(1), avgGrade FLOAT )});
#$ScholarDbh->do(q{CREATE TABLE personalInfo (fn VARCHAR(10) PRIMARY KEY , name VARCHAR(100), phoneNumber VARCHAR(15), egn VARCHAR(10), address VARCHAR(200), CONSTRAINT fk_personalInfo Foreign KEY (fn) REFERENCES studentInfo (fn))});
#$ScholarDbh->do(q{CREATE TABLE familyInfo (fn VARCHAR(10) PRIMARY KEY , father VARCHAR(100), mother VARCHAR(100), sibling VARCHAR(100), CONSTRAINT fk_familyInfo Foreign KEY (fn) REFERENCES studentInfo (fn))});
#$ScholarDbh->do(q{CREATE TABLE incomeInfo (fn VARCHAR(10) PRIMARY KEY , wage FLOAT, pension FLOAT, bonus FLOAT, scholarships FLOAT, others FLOAT, total FLOAT, avg FLOAT,CONSTRAINT fk_incomeInfo Foreign KEY (fn) REFERENCES studentInfo (fn))});
#$ScholarDbh->do(q{CREATE TABLE bankInfo (fn VARCHAR(10) PRIMARY KEY , bankName VARCHAR(50), iban VARCHAR(50),CONSTRAINT fk_bankInfo Foreign KEY (fn) REFERENCES studentInfo (fn))});

#$ScholarDbh->disconnect()
