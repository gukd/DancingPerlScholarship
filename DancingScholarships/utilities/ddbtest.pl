#!/usr/bin/perl


use warnings;
use utf8;
use DBI;

use Encode qw(encode_utf8);
open my $out2, '>', "dbtest2.txt";


use Encode qw(encode_utf8);
open my $out3, '>', "dbtest3.txt";

#$dbh->do(q{CREATE TABLE accounts (username VARCHAR(50), password VARCHAR(50), fn VARCHAR(10) PRIMARY KEY)});
#$dbh->do(q{CREATE TABLE userInfo (fn VARCHAR(10), name VARCHAR(100), Note FLOAT, PRIMARY KEY (fn), CONSTRAINT fk_userInfo FOREIGN KEY (fn) REFERENCES accounts (fn))});

my $susiDbh = DBI -> connect ("DBI:SQLite:susitest.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr ;
my $printUser = $susiDbh->prepare(q{SELECT * FROM userInfo GROUP BY fn });
my $printAccount = $susiDbh->prepare(q{SELECT * FROM accounts GROUP BY fn });
my $ScholarDbh = DBI -> connect ("DBI:SQLite:scholarships.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr ;

my $insertStudentInfo = $ScholarDbh->prepare(q{INSERT INTO studentInfo VALUES (:fn , :faculty , :specialty , :year , :studyYear , :semester , :grade)});
my $insertPersonalInfo = $ScholarDbh->prepare(q{INSERT INTO personalInfo VALUES (:fn , :name , :phone , :egn , :address)});
my $insertFamilyInfo = $ScholarDbh->prepare(q{INSERT INTO familyInfo VALUES (:fn , :father , :mother , :siblings)});
my $insertIncomeInfo = $ScholarDbh->prepare(q{INSERT INTO incomeInfo VALUES (:fn , :wage , :pension , :bonus , :scholarship , :others , :total , :avg)});
my $insertBankInfo = $ScholarDbh->prepare(q{INSERT INTO bankInfo VALUES (:fn , :bank , :ibn)});

#$susiDbh->do(q{INSERT INTO accounts VALUES ('georgig' , 'abv','80718')});
#$susiDbh->do(q{INSERT INTO userInfo VALUES ('80718' , 'georgi dimitrov urumov' , '5.23')});

#studentInfo s, personalInfo p, familyInfo f, incomeInfo i,bankInfo b  AND p.fn = :fn AND f.fn = :fn AND i.fn = :fn AND b.fn = :fn});

my $deletes = $ScholarDbh -> prepare(q{DELETE FROM studentInfo WHERE fn = :fn});
my $deletep = $ScholarDbh -> prepare(q{DELETE FROM personalInfo WHERE fn = :fn});
my $deletef = $ScholarDbh -> prepare(q{DELETE FROM familyInfo WHERE fn = :fn});
my $deletei = $ScholarDbh -> prepare(q{DELETE FROM incomeInfo WHERE fn = :fn});
my $deleteb = $ScholarDbh -> prepare(q{DELETE FROM bankInfo WHERE fn = :fn});

my $fn = 10011;
my $faculty = "a";
my $specialty = "b"; 
my $year = 2000;
my $studyYear = 2;
my $semester = 2;
my $avgGrade = 5.89;
my $name = "gu";
my $phoneNumber = "0895";
my $egn = 1214;
my $address = "asdf";
my $father = "m";
my $mother = "m";
my $sibling = "n";
my $wage = 1000;
my $pension = 0;
my $bonus = 0;
my $scholarships = 0;
my $others = 0;
my $total = 1000;
my $avg = 300;
my $bankName = "dsk";
my $iban = 123;


#$insertStudentInfo -> execute($fn, $faculty, $specialty, $year, $studyYear, $semester, $grade);
#$insertPersonalInfo-> execute($fn, $name, $phone, $egn, $address);
#$insertFamilyInfo-> execute($fn, $father, $mother, $siblings);
#$insertIncomeInfo-> execute($fn, $wage, $pension, $bonus, $scholarships, $other, $total, $other);
#$insertBankInfo -> execute($fn, $bank, $ibn);

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
    $ScholarDbh->commit;
    return 1;
  }

}

#&createEntry ($fn, $faculty, $specialty, $year, $studyYear, $semester, $avgGrade, $name, $phoneNumber, $egn, $address, $father, $mother, $sibling, $wage, $pension, $bonus, $scholarships, $others, $total, $avg, $bankName, $iban) ;
#$deletes ->execute(80716);
#$deletep ->execute(80716);
#$deletef ->execute(80716);
#$deletei ->execute(80716);
#$deleteb ->execute(80716);

#my $adminGetTableBy = $ScholarDbh->prepare(q{SELECT s.fn, s.faculty, s.specialty, s.year, s.studyYear, s.semester, s.avgGrade, p.name, p.phoneNumber, p.egn, p.address, f.father, f.mother, f.sibling, i.wage, i.pension, i.bonus, i.scholarships, i.others, i.total, i.avg, b.bankName, b.iban FROM studentInfo s INNER JOIN  personalInfo p  ON s.fn == p.fn INNER JOIN familyInfo f ON f.fn == s.fn INNER JOIN incomeInfo i ON i.fn == s.fn INNER JOIN bankInfo b ON b.fn == s.fn ORDER BY :param });
#$adminGetTableBy->execute("s.avgGrade");
#my $printEntries = $ScholarDbh->prepare(q{SELECT s.fn, s.faculty, s.specialty, s.year, s.studyYear, s.semester, s.avgGrade, p.name, p.phoneNumber, p.egn, p.address, f.father, f.mother, f.sibling, i.wage, i.pension, i.bonus, i.scholarships, i.others, i.total, i.avg, b.bankName, b.iban FROM studentInfo s INNER JOIN  personalInfo p  ON s.fn = p.fn INNER JOIN familyInfo f ON f.fn = s.fn INNER JOIN incomeInfo i ON i.fn = s.fn INNER JOIN bankInfo b ON b.fn = s.fn ORDER BY s.avgGrade DESC});
#$printEntries -> execute();

$printUser -> execute();
$printAccount -> execute();

while (my @res = $printUser->fetchrow_array) {
    print  "@res\n";
};

while (my @res = $printAccount->fetchrow_array) {
    print "@res\n";
};

while (my @res = $adminGetTableBy->fetchrow_array) {
    my $grade = $res[6];
    print "$grade\n";
};

#while (my @res = $printEntries->fetchrow_array) {
#    print "@res\n";
#};

$ScholarDbh -> disconnect();
$susiDbh -> disconnect();