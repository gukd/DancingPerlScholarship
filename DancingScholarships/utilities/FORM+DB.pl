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

my $index_template=<<EOF;
<html>
<body>

<h1>Hello From Self-Contained Dancer Application</h1>

<% IF missing_name %>
<h2>please enter your name!</h2>
<% END %>
<form action="<% request.uri_for("/") %>" method="post">

Name:   <input type="text" name="name" size = "50">  <br>
FN:   <input type="text" name="fn" size = "50">  <br>
Note:   <input type="text" name="note" size = "50">  <br>
Phone:  <input type="text" name="phn"  size = "10">  <br>
EGN:    <input type="text" name="egn"  size = "10">  <br>
Address:<input type="text" name="addr" size = "100"> <br>
<input type="submit" name="submit" value="Submit Form" />
</form>

</body>
</html>

EOF

get '/' => sub {
        my $t = engine 'template';
        my $r = request ;
        return $t->render(\$index_template, { request => $r } );
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
        my $fn = param 'fn';
        my $note = param 'note';
        my $phn = param 'phn';
        my $egn = param 'egn';
        my $addr = param 'addr';

        $sbh->execute($fn , $name , $note);
        return $t->render(\$index_template, { request => $r, missing_name => 1} )
                unless $name;

        return $t->render(\$hello_template, { request => $r, name => $name, phn => $phn, fn => $fn, note => $note, egn => $egn, addr => $addr} );

};

dance;

$dbh->disconnect();