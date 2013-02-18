#!/usr/bin/env perl
use strict;
use warnings;
use Dancer;
use DBI;

set log => "core";
set logger => "console";
set warnings => 1;
set template => "simple";

my $dbh = DBI -> connect ("DBI:SQLite:susitest.dbl","","",{RaiseError => 1, sqlite_unicode => 1}) or die $DBI::errstr;
#$dbh->do(q{CREATE TABLE accounts (username VARCHAR(50), password VARCHAR(50), fn VARCHAR(10) PRIMARY KEY)});
#$dbh->do(q{CREATE TABLE userInfo (fn VARCHAR(10), name VARCHAR(100), Note FLOAT, PRIMARY KEY (fn), CONSTRAINT fk_userInfo FOREIGN KEY (fn) REFERENCES accounts (fn))});
my $sbh = $dbh->prepare(q{INSERT INTO userInfo VALUES (:fn , :name , :note)});


get '/' => sub {
        template 'index'
        #my $t = engine 'template';
        #my $r = request ;
        #return $t->render(\$index_template, { request => $r } );
};

my $hello_template=<<EOF;
<html>
<body>
<h1>Hello <% name %>, your phonenumber is: <% phn %>, egn: <% egn %>, fn: <% fn %>, notes: <% note %> and you at <% addr %>.</h1>

Thanks for using Dancer!
<br/>
<br/>
If that's not your correct info? , <a href="<% request.uri_base %>"> Click here to re-enter and submit.</a>
</body>
</html>
EOF

post '/' => sub {
        my $t = engine 'template';
        my $r = request;
        my $name = param 'name';
        my $fn = param 'fNumber';
        my $note = param 'avgGrade';
        my $phn = param 'phone';
        my $egn = param 'egn';
        my $addr = param 'address';

        $sbh->execute($fn , $name , $note);
        #return $t->render(\$index_template, { request => $r, missing_name => 1} )
         #       unless $name;

        return $t->render(\$hello_template, { request => $r, name => $name, phone => $phn, fNumber => $fn, avgGrade => $note, egn => $egn, address => $addr} );

};

dance;

$dbh->disconnect();