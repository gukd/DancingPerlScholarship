#!/usr/bin/env perl
use strict;
use warnings;
use Dancer;
use Dancer::Plugin::Database;
use Dancer::Plugin::SimpleCRUD;

set template => 'simple';
set log => "debug";
set logger => "console";
set warnings => 1;
set plugins => { Database => { driver => 'SQLite', database => "foo.sqlite" } } ;

my $index_template=<<EOF;
<html>
<head>
</head>
<body>

<h1>Hello From Self-Contained Dancer Application</h1>
<h2>(With Database plugin support)</h2>

<h3>Add a new shape to database</h3>
<form action="add" method="post">
        Shape: <select name="shape">
                <option value="square">square</option>
                <option value="circle">circle</option>
                <option value="triangle">triangle</option>
                </select>

        Color: <select name="color">
                <option value="red">red</option>
                <option value="green">green</option>
                <option value="blue">blue</option>
                </select>

        <input type="submit" name="submit" value="Add Shape" />
</form>

Direct Database Access: <a href="shapes">click here</a><br/>

<h3>Current Shapes in database:</h3>
<% IF shapes.size == 0 %>
  Database is empty. Please add some shapes.
<% ELSE %>
  <% FOREACH s IN shapes %>
    <% s.count %> <% s.color %> <% s.shape %><% s.count>1 ? 's' : '' %>
    <br/>
  <% END %>
<% END %>

</body>
</html>
EOF

get '/' => sub {
        my $t = engine 'template';
        my $sql="SELECT shape,color,count(id) AS count FROM shapes GROUP BY shape,color";
        my $s = database->prepare($sql);
        $s->execute();
        my $shapes = $s->fetchall_arrayref({}) ;
        return $t->render(\$index_template, { shapes => $shapes } );
};

post '/add' => sub {
        my $shape = params->{shape} or die "missing shape parameter";
        my $color = params->{color} or die "missing color parameter";
        $shape =~ s/[^\w]//g; # minimal input sanitization
        $color =~ s/[^\w]//g;
        database->quick_insert( 'shapes', { shape=>$shape, color=>$color } );

        ## The shape was added to the DB, send to user back to the main page.
        redirect '/';
};

simple_crud (
        record_title => 'Shape',
        prefix => '/shapes',
        db_table => 'shapes',
        editable => 1,
        deletable => 1,
        sortable => 1
);

##
## On-time application initialization: create the database
##
sub init_db
{
        ## Create a SHAPE table if it doesn't exist
        my $sql=<<EOF;
        CREATE TABLE IF NOT EXISTS shapes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                shape TEXT,
                color TEXT,
                time TIMESTAMP default CURRENT_TIMESTAMP )
EOF
        database->do($sql);
}

init_db;
dance;