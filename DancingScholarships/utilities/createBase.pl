#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use DBI;

my $ScholarDbh = DBI -> connect ("DBI:SQLite:scholarships.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr ;
$ScholarDbh->do(q{CREATE TABLE studentInfo (fn VARCHAR(10) PRIMARY KEY , faculty VARCHAR(100), specialty VARCHAR(50), year VARCHAR(10), studyYear VARCHAR(1), semester VARCHAR(1), avgGrade FLOAT )});
$ScholarDbh->do(q{CREATE TABLE personalInfo (fn VARCHAR(10) PRIMARY KEY , name VARCHAR(100), phoneNumber VARCHAR(15), egn VARCHAR(10), address VARCHAR(200), CONSTRAINT fk_personalInfo Foreign KEY (fn) REFERENCES studentInfo (fn))});
$ScholarDbh->do(q{CREATE TABLE familyInfo (fn VARCHAR(10) PRIMARY KEY , father VARCHAR(100), mother VARCHAR(100), sibling VARCHAR(100), CONSTRAINT fk_familyInfo Foreign KEY (fn) REFERENCES studentInfo (fn))});
$ScholarDbh->do(q{CREATE TABLE incomeInfo (fn VARCHAR(10) PRIMARY KEY , wage FLOAT, pension FLOAT, bonus FLOAT, scholarships FLOAT, others FLOAT, total FLOAT, avg FLOAT,CONSTRAINT fk_incomeInfo Foreign KEY (fn) REFERENCES studentInfo (fn))});
$ScholarDbh->do(q{CREATE TABLE bankInfo (fn VARCHAR(10) PRIMARY KEY , bankName VARCHAR(50), iban VARCHAR(50),CONSTRAINT fk_bankInfo Foreign KEY (fn) REFERENCES studentInfo (fn))});

$ScholarDbh->disconnect()