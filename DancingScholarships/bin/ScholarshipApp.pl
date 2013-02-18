#!/usr/bin/env perl
use strict;
use warnings;
use Dancer;
use DBI;
use utf8;
use FindBin;
use Encode qw(encode_utf8);
use encoding 'utf8', Filter => 1;

my $susiDbh = DBI -> connect ("DBI:SQLite:susitest.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr ;
my $scholarDbh = DBI -> connect ("DBI:SQLite:scholarships.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr;
 
my $susiUserCheck = $susiDbh -> prepare(q{SELECT password FROM accounts WHERE username = :name});
my $susiRetrieveFN = $susiDbh -> prepare(q{SELECT fn FROM accounts WHERE username = :name});
my $susiRetrieveGrade = $susiDbh -> prepare(q{SELECT grade FROM userInfo WHERE fn = :fn});

my $insertStudentInfo = $scholarDbh->prepare(q{INSERT INTO studentInfo VALUES (:fn , :faculty , :specialty , :acadYear , :courseNumber , :semester , :avgGrade)});
my $insertPersonalInfo = $scholarDbh->prepare(q{INSERT INTO personalInfo VALUES (:fn , :name , :phone , :egn , :address)});
my $insertFamilyInfo = $scholarDbh->prepare(q{INSERT INTO familyInfo VALUES (:fn , :father , :mother , :siblings)});
my $insertIncomeInfo = $scholarDbh->prepare(q{INSERT INTO incomeInfo VALUES (:fn , :wage , :pension , :bonus , :scholarship , :others , :total , :avg)});
my $insertBankInfo = $scholarDbh->prepare(q{INSERT INTO bankInfo VALUES (:fn , :bank , :iban)});

my $adminUserCheck = $susiDbh -> prepare(q{SELECT password FROM admins WHERE username = :name});
my $adminGetTableBy = $scholarDbh->prepare(q{SELECT s.fn, s.faculty, s.specialty, s.year, s.studyYear, s.semester, s.avgGrade, p.name, p.phoneNumber, p.egn, p.address, f.father, f.mother, f.sibling, i.wage, i.pension, i.bonus, i.scholarships, i.others, i.total, i.avg, b.bankName, b.iban FROM studentInfo s INNER JOIN  personalInfo p  ON s.fn == p.fn INNER JOIN familyInfo f ON f.fn == s.fn INNER JOIN incomeInfo i ON i.fn == s.fn INNER JOIN bankInfo b ON b.fn == s.fn ORDER BY :param DESC});
my $adminGetFirstnSimple = $scholarDbh->prepare(q{SELECT s.fn, p.name, s.faculty, s.specialty, s.year, s.studyYear, s.semester, s.avgGrade FROM studentInfo s INNER JOIN personalInfo p ON s.fn = p.fn ORDER BY s.fn DESC LIMIT :n});

sub checkUserAndFetchFN
{
  my ($uname,$pass) = @_;   
  $susiUserCheck->execute($uname);
  my @res = $susiUserCheck->fetchrow_array();
  if (scalar(@res) == 0 || ($res[0] ne $pass)) 
  {
    return 0; 
  }
  else
  {
    $susiRetrieveFN -> execute($uname);
    my @fn = $susiRetrieveFN->fetchrow_array();
    if (scalar(@fn) != 1) 
    {
      return 0; 
    }
    else
    {
      return $fn[0];  
    }
  }
}

sub checkAdminUser
{
  my ($uname,$pass) = @_;   
  $adminUserCheck->execute($uname);
  my @res = $adminUserCheck->fetchrow_array();
  if (scalar(@res) == 0 || ($res[0] ne $pass)) 
  {
    return 0; 
  }
  else
  {
    return 1;
  }
}

sub getGrade
{
  my $fn = shift @_;
  $susiRetrieveGrade -> execute($fn);
  my @avgGrade = $susiRetrieveGrade -> fetchrow_array();
  if ( $avgGrade[0] =~ m/[2-6][.]*[0-9]*/ && $avgGrade[0] <= 6)
  {
     return $avgGrade[0];
  }
  else
  {
    return 0;
  }  
}

sub createEntry 
{
  my ($fn, $faculty, $specialty, $acadYear, $courseNumber, $semester, $avgGrade, $name, $phoneNumber, $egn, $address, $father, $mother, $sibling, $wage, $pension, $kidAid, $scholarships, $other, $total, $incomePerPerson, $bankName, $iban) = @_ ;
  $scholarDbh->begin_work;
  eval 
  {
    $insertStudentInfo->execute($fn, $faculty, $specialty, $acadYear, $courseNumber, $semester, $avgGrade) or die "Couldn't access the DB! Rolling back!";
    $insertPersonalInfo->execute($fn, $name, $phoneNumber, $egn, $address) or die "Couldn't access the DB! Rolling back!";
    $insertFamilyInfo->execute($fn, $father, $mother, $sibling) or die "Couldn't access the DB! Rolling back!";
    $insertIncomeInfo->execute($fn, $wage, $pension, $kidAid, $scholarships, $other, $total, $incomePerPerson) or die "Couldn't access the DB! Rolling back!";
    $insertBankInfo->execute($fn, $bankName, $iban) or die "Couldn't access the DB! Rolling back!";
  };
  if($@) 
  {
    $insertStudentInfo->finish;
	$insertPersonalInfo->finish;
	$insertFamilyInfo->finish;
	$insertIncomeInfo->finish;
	$insertBankInfo->finish;
    $scholarDbh->rollback;
    return 0;
  }
  else
  { 
    $scholarDbh->commit;
	$insertStudentInfo->finish;
	$insertPersonalInfo->finish;
	$insertFamilyInfo->finish;
	$insertIncomeInfo->finish;
	$insertBankInfo->finish;
    return 1;
  }
}

sub calculateScholarships
{
  my ($budget, $months, $g40, $g50, $g55, $g56, $g57, $g58, $g59, $g60) = @_;
  open my $out, '>', "$FindBin::Bin/../public/scholarschips.txt";
  $adminGetTableBy->execute("s.avgGrade");
  my $full40 = $months * $g40;
  my $full50 = $months * $g50;
  my $full55 = $months * $g55;
  my $full56 = $months * $g56;
  my $full57 = $months * $g57;
  my $full58 = $months * $g58;
  my $full59 = $months * $g59;
  my $full60 = $months * $g60;
  
  while ($budget >= $full40 && (my @res = $adminGetTableBy->fetchrow_array))
  {
    my $gradePositionInTable = 6;
    my $grade = $res[$gradePositionInTable];
	
	if ($grade == 6)
	{if ($budget - $full60 >= 0) {$budget -= $full60; print {$out} encode_utf8 "@res " . "$g60\n"}}
	elsif ($grade >= 5.90)
	{if ($budget - $full59 >= 0) {$budget -= $full59; print {$out} encode_utf8 "@res " . "$g59\n"}}
	elsif ($grade >= 5.80)
	{if ($budget - $full58 >= 0) {$budget -= $full58; print {$out} encode_utf8 "@res " . "$g58\n"}}
	elsif ($grade >= 5.70)
	{if ($budget - $full57 >= 0) {$budget -= $full57; print {$out} encode_utf8 "@res " . "$g57\n"}}
	elsif ($grade >= 5.60)
	{if ($budget - $full56 >= 0) {$budget -= $full56; print {$out} encode_utf8 "@res " . "$g56\n"}}
	elsif ($grade >= 5.50)
	{if ($budget - $full55 >= 0) {$budget -= $full55; print {$out} encode_utf8 "@res " . "$g55\n"}}
	elsif ($grade >= 5.00)
	{if ($budget - $full50 >= 0) {$budget -= $full50; print {$out} encode_utf8 "@res " . "$g50\n"}}
	elsif ($grade >= 4.00)
	{if ($budget - $full40 >= 0) {$budget -= $full40; print {$out} encode_utf8 "@res " . "$g40\n"}}
  };
  
  close $out;
}

get '/' => sub {
    template 'LogIn';
};

post '/' => sub {
     my $acc = param 'acc';
     my $pass = param 'pass';
     my $admin = param 'admin';
     if ($admin)
     {
       if(&checkAdminUser($acc, $pass))
       { 
         redirect '/AdminPanel';
       }
       else
       { 
         forward '/Error', {'field' => 'невалидно администраторско име или парола!'};
       }
     }
     else
     {
       my $fn = &checkUserAndFetchFN ($acc, $pass);
       if ($fn)
       {   
         set FN => "$fn";
         redirect '/ScholarshipForm';
       }
       else
       {
         forward '/Error' , {'field' => 'невалидно потребителско име или парола!'};
       }
     }
};

get '/ScholarshipForm' => sub {
    template 'ScholarshipForm';
};

post '/ScholarshipForm' => sub {

	 #Personal Info:
         my $name = param 'name'; if($name !~ m/[a-zа-я]([a-zа-я]|\s){0,98}/i) {forward  '/Error' , { 'field' => 'некоректно име'}}
	 my $phoneNumber = param 'phoneNumber'; if($phoneNumber !~ m/\+?[0-9]{10,15}/) {forward  '/Error' , { 'field' => 'некоректен телефонен номер'}}
	 my $egn = param 'egn';	if($egn !~ m/[0-9]{10}/) {forward  '/Error' , { 'field' => 'некоректно ЕГН'}}
	 my $address = param 'address'; if($address !~ m/[a-zа-я]([a-zа-я]|\s){0,198}/i) {forward '/Error' , {'field' => 'некоректен адрес'}}
	
	 #Student Info:
	 my $faculty = param 'faculty'; if($faculty !~ m/[a-zа-я]([a-zа-я]|\s){0,98}/i) {forward '/Error' , {'field' => 'некоректно име на факултет'}}
	 my $specialty = param 'specialty'; if($specialty !~ m/[a-zа-я]([a-zа-я]|\s){0,48}/i) {forward '/Error' , {'field' => 'некоректно име на специалност'}}
         my $fn = param 'fn'; if($fn !~ m/[0-9]{5,10}/ || $fn != setting('FN')) {forward '/Error', {'field' => 'некоректен факултетен номер!'}}
	 my $courseNumber = param 'courseNumber'; if($courseNumber !~ m/1|2|3|4|5/) {forward '/Error', {'field' => 'некоректен курс'}}
	 my $acadYear = param 'acadYear'; 
	 my $semester = param 'semester'; if($semester !~ m/1|2/) {forward '/Error', {'field' => 'некорекен номер на семестър'}}
         my $avgGrade = param 'avgGrade'; if ($avgGrade !~ m/[4-6]\.?[0-9]*/ || $avgGrade > 6 || $avgGrade != &getGrade(setting('FN')) ) {forward '/Error', {'field' => 'некоректна оценка! Според базата имате '. &getGrade(setting('FN'))}}

	 #Family Status:
	 my $father = param 'father'; if($father !~ m/[a-zа-я]([a-zа-я]|\s){0,98}/i) {forward  '/Error' , { 'field' => 'некоректно име на баща'}}
	 my $mother = param 'mother'; if($mother !~ m/[a-zа-я]([a-zа-я]|\s){0,98}/i) {forward  '/Error' , { 'field' => 'некоректно име на майка'}}
	 my $sibling = param 'sibling'; if($sibling !~ m/[a-zа-я]([a-zа-я]|\s){0,98}/i) {forward  '/Error' , { 'field' => 'некоректно име на брат/сестра'}}
	
	 #Family Income:
	 my $wage = param 'wage'; if ($wage < 0) {forward  '/Error' , { 'field' => 'некоректна стойност за заплата'}}
	 my $pension = param 'pension'; if ($wage < 0) {forward  '/Error' , { 'field' => 'некоректна стойност за пенсия'}}
	 my $kidAid = param 'kidAid'; if ($wage < 0) {forward  '/Error' , { 'field' => 'некоректна стойност за добавки'}} 
	 my $scholarships = param 'scholarships'; if ($wage < 0) {forward  '/Error' , { 'field' => 'некоректна стойност за стипендии'}}
	 my $other = param 'other'; if ($wage < 0) {forward  '/Error' , { 'field' => 'некоректна стойност за \"други\"'}}
	 my $total = param 'total'; if ($wage < 0) {forward  '/Error' , { 'field' => 'некоректна стойност на общия доход '}}
	 my $incomePerPerson = param 'incomePerPerson'; if ($wage < 0) {forward  '/Error' , { 'field' => 'некоректна стойност за доход на член от семейството'}}
	
	 #Bank Info:
	 my $bankName = param 'bankName'; if($bankName !~ m/[a-zа-я]([a-zа-я]|\s){0,50}/i) {forward  '/Error' , { 'field' => 'некоректно име на банка'}}
	 my $iban = param 'iban';  if($iban !~ m/[a-z]([a-z]|\s){0,48}/i){forward  '/Error' , { 'field' => 'некоректен IBAN'}}

	 if (&createEntry($fn, $faculty, $specialty, $acadYear, $courseNumber, $semester, $avgGrade + 0, $name, $phoneNumber, $egn, $address, $father, $mother, $sibling, $wage, $pension, $kidAid, $scholarships, $other, $total, $incomePerPerson, $bankName, $iban))
     {
       forward '/Success'  => {'message' => 'Успешно изпратихте вашето заявление!'};
	 }
	 else
	 {
	   forward '/Error' , {field => 'повтарящ се запис!'};
	 }
};

get '/AdminPanel' => sub {
    template 'AdminPanel';
};

post '/AdminPanel' => sub {
     my $function = param 'queryType';
	 if ($function eq 'more')
	 {
       my $amount = 5;
       open my $out, '>', "$FindBin::Bin/../public/query.txt";
	   $adminGetFirstnSimple->execute($amount);
	   while (my @res = $adminGetFirstnSimple->fetchrow_array)
	   {
         print {$out} encode_utf8 "@res\n";
       };
	   close $out;
	   forward '/Success' => {'message' => 'Може да свалите резултата от <a href="query.txt">тук</a>'};		
	 }
	 elsif ($function eq 'calculate')
	 {
	   redirect '/Calculate';
	 }
	 elsif ($function eq 'showBase')
	 {
	   $adminGetTableBy->execute('s.fn');
	   open my $out, '>', "$FindBin::Bin/../public/base.txt";
	   while (my @res = $adminGetTableBy->fetchrow_array)
	   {
	     printf {$out} encode_utf8 "%-10s %-50s %-30s %-50s %-10s %-2s %-2s %-8s %-100s %-15s %-10s %-100s %-50s %-50s %-50s %-6s %-4s %-4s %-4s %-4s %-6s %-4s %-50s %-50s\n", @res;
         #print {$out} encode_utf8 "@res\n";
       };
	   close $out;
	   forward '/Success' => {'message' => 'Може да свалите резултата от <a href="base.txt">тук</a>'};		
	 }
};

get '/Calculate' => sub{
    template 'Calculate';
};

post '/Calculate' => sub{
     my $grade400 = param 'grade400';
	 my $grade500 = param 'grade500';
	 my $grade550 = param 'grade550';
	 my $grade560 = param 'grade560';
	 my $grade570 = param 'grade570';
	 my $grade580 = param 'grade580';
	 my $grade590 = param 'grade590';
	 my $grade600 = param 'grade600';
	 my $budget = param 'totalAmmount';
	 my $months = param 'months';
	
	 &calculateScholarships($budget, $months, $grade400, $grade500, $grade550, $grade560, $grade570, $grade580, $grade590, $grade600 );
	
	 forward '/Success' => {'message' => 'Може да свалите резултата от <a href="scholarschips.txt">тук</a>'};
};

post '/Success' => sub {
     template 'Success' => {message => params -> {message}}; 
};

post '/Error' => sub {
     template 'Error' => {field => params -> {field}};
};

dance;

$susiDbh->disconnect();
$scholarDbh->disconnect();