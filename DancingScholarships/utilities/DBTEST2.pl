#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use DBI;

use Encode qw(encode_utf8);
open my $out, '>', "dbtest2.txt";

my $ScholarDbh = DBI -> connect ("DBI:SQLite:scholarships.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr ;
my $insertStudentInfo = $ScholarDbh->prepare(q{INSERT INTO studentInfo VALUES (:fn , :faculty , :specialty , :year , :studyYear , :semester , :grade)});
my $insertPersonalInfo = $ScholarDbh->prepare(q{INSERT INTO personalInfo VALUES (:fn , :name , :phone , :egn , :address)});
my $insertFamilyInfo = $ScholarDbh->prepare(q{INSERT INTO familyInfo VALUES (:fn , :father , :mother , :siblings)});
my $insertIncomeInfo = $ScholarDbh->prepare(q{INSERT INTO incomeInfo VALUES (:fn , :wage , :pension , :bonus , :scholarship , :others , :total , :avg)});
my $insertBankInfo = $ScholarDbh->prepare(q{INSERT INTO bankInfo VALUES (:fn , :bank , :ibn)});

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

#&createEntry (1 ,a ,b , 2000 , 2 , 2 , 5 , gu , 0895 , 123 , asd , m , m , n , 1000 , 0 , 0 , 0 , 0 , 1000 , 300 , dsk , iban );
#&createEntry (2 ,a ,b , 2000 , 2 , 2 , 5 , gu , 0895 , 123 , asd , m , m , n , 1000 , 0 , 0 , 0 , 0 , 1000 , 300 , dsk , iban );
#&createEntry (3 ,a ,b , 2000 , 2 , 2 , 5 , gu , 0895 , 123 , asd , m , m , n , 1000 , 0 , 0 , 0 , 0 , 1000 , 300 , dsk , iban );

my $printEntry = $ScholarDbh->prepare(q{SELECT s.fn, s.faculty, s.specialty, s.year, s.studyYear, s.semester, s.avg, p.name, p.phoneNumber, p.egn, p.address, f.father, f.mother, f.sibling, i.wage, i.pension, i.bonus, i.scholarships, i.other, i.total, b.bankName, b.iban FROM studentInfo s, personalInfo p, familyInfo f, incomeInfo i, bankInfo b WHERE s.fn == :fn AND p.fn == :fn AND f.fn == :fn AND i.fn == :fn AND b.fn == :fn});
$printEntry -> execute(1);
while (my @res = $printEntry->fetchrow_array) {
    print {$out} encode_utf8 "@res\n";
}