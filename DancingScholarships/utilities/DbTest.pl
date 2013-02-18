#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use DBI;


#use open qw/:std :utf8/;

use Encode qw(encode_utf8);
open my $out, '>', "dbtest.txt";

my $susiDbh = DBI -> connect ("DBI:SQLite:susitest.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr ;

#Test functions
my $insertAccount = $susiDbh->prepare(q{INSERT INTO accounts VALUES (:uname , :pass, :fn)});
my $insertUserInfo = $susiDbh->prepare(q{INSERT INTO userInfo VALUES (:fn , :name , :grade)});

my $printAccount = $susiDbh->prepare(q{SELECT * FROM accounts GROUP BY fn });
my $printUser = $susiDbh->prepare(q{SELECT * FROM userInfo GROUP BY fn });

my $susiUserCheck = $susiDbh -> prepare("SELECT a.password FROM accounts a WHERE a.username = :name ");
my $susiRetrieveFN = $susiDbh -> prepare("SELECT a.fn FROM userInfo a WHERE a.username = :name ")
 
sub checkUserAndFetchFN
{
   my ($uname,$pass) = @_;   
   $susiUserCheck->execute($uname);
   my @res = $susiUserCheck->fetchrow_array();
   if (scalar(@res) == 0 || ($res[0] ne $pass)) 
   {
     return -1; 
   }
   else
   {
     $susiRetrieveFN -> execute($uname);
     my @fn = $susiRetrieveFN->fetchrow_array();
     if (scalar(@fn) != 1) 
     {
       return -1; 
     }
     else
     {
       return $fn[0];  
     }
   }
}



#dbase for the scholarships
my $ScholarDbh = DBI -> connect ("DBI:SQLite:scholarships.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr ;

my $insertStudentInfo = $ScholarDbh->prepare(q{INSERT INTO studentInfo VALUES (:fn , :faculty , :specialty , :year , :studyYear , :semester , :grade)});
my $insertPersonalInfo = $ScholarDbh->prepare(q{INSERT INTO personalInfo VALUES (:fn , :name , :phone , :egn , :address)});
my $insertFamilyInfo = $ScholarDbh->prepare(q{INSERT INTO familyInfo VALUES (:fn , :father , :mother , :siblings)});
my $insertIncomeInfo = $ScholarDbh->prepare(q{INSERT INTO incomeInfo VALUES (:fn , :wage , :pension , :bonus , :scholarship , :others , :total , :avg)});
my $insertBankInfo = $ScholarDbh->prepare(q{INSERT INTO bankInfo VALUES (:fn , :bank , :ibn)});


my $printStudentInfo = $ScholarDbh->prepare(q{SELECT * FROM studentInfo GROUP BY fn });
my $printPersonalInfo = $ScholarDbh->prepare(q{SELECT * FROM personalInfo GROUP BY fn });
my $printFamilyInfo = $ScholarDbh->prepare(q{SELECT * FROM familyInfo GROUP BY fn });
my $printIncomeInfo = $ScholarDbh->prepare(q{SELECT * FROM incomeInfo GROUP BY fn });
my $printBankInfo =$ScholarDbh->prepare(q{SELECT * FROM bankInfo GROUP BY fn });

my $printEntry = $ScholarDbh->prepare(q{SELECT s.fn, s.faculty, s.specialty, s.year, s.studyYear, s.semester, s.avgGrade, p.name, p.phoneNumber, p.egn, p.address, f.father, f.mother, f.sibling, i.wage, i.pension, i.bonus, i.scholarships, i.others, i.total, b.bankName, b.iban FROM studentInfo s, personalInfo p, familyInfo f, incomeInfo i, bankInfo b WHERE s.fn == :fn AND p.fn == :fn AND f.fn == :fn AND i.fn == :fn AND b.fn == :fn});

my $printEntries = $ScholarDbh->prepare(q{SELECT s.fn, s.faculty, s.specialty, s.year, s.studyYear, s.semester, s.avgGrade, p.name, p.phoneNumber, p.egn, p.address, f.father, f.mother, f.sibling, i.wage, i.pension, i.bonus, i.scholarships, i.others, i.total, b.bankName, b.iban FROM studentInfo s INNER JOIN  personalInfo p  ON s.fn = p.fn INNER JOIN familyInfo f ON f.fn = s.fn INNER JOIN incomeInfo i ON i.fn = s.fn INNER JOIN bankInfo b ON b.fn = s.fn GROUP BY s.fn});


sub createEntry 
{
  my ($fn, $faculty, $specialty, $year, $studyYear, $semester, $avgGrade, $name, $phoneNumber, $egn, $address, $father, $mother, $sibling, $wage, $pension, $bonus, $scholarships, $others, $total, $avg, $bankName, $iban) = @_ ;
  $ScholarDbh->begin_work;
  eval 
  {
    $insertStudentInfo->execute($fn, $faculty, $specialty, $year, $studyYear, $semester, $avgGrade) or die "Couldn't access the DB! Rolling back!";
    $insertPersonalInfo->execute($fn, $name, $phoneNumber, $egn, $address) or die "Couldn't access the DB! Rolling back!";
    $insertFamilyInfo->execute($fn, $father, $mother, $sibling) or die "Couldn't access the DB! Rolling back!";
    $insertIncomeInfo->execute($fn, $wage, $pension, $bonus, $scholarships, $others, $total, $avg) or die "Couldn't access the DB! Rolling back!";
    $insertBankInfo->execute($fn, $bankName, $iban) or die "Couldn't access the DB! Rolling back!";
  };
  if($@) 
  {
    $insertStudentInfo->finish;
    $ScholarDbh->rollback;
    return 0;
  }
  else
  {
    #print "Added user $uname with password $pass !"; 
    $ScholarDbh->commit;
    return 1;
  }
}



while (my @res = $printUser ->fetchrow_array) {
   print {$out} encode_utf8 "@res\n";
}

$susiDbh->disconnect();
$ScholarDbh->disconnect();
close $out;