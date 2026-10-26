#!/usr/bin/env perl
use strict;
use warnings;
use DBI;
use Getopt::Std;

# Local counterpart of HyperTRIBE's load_matrix_data.pl.
# Match the reference database defaults: localhost / dmseq / root / empty password.

my %option;
getopts('t:d:h', \%option);
my ($tablename, $matrixfile) = @option{qw(t d)};
die "Usage: $0 -t tablename -d datafile\n" unless $tablename && $matrixfile;
die "Invalid table name: $tablename\n" unless $tablename =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/;

my $dsn = "DBI:mysql:dmseq:localhost";
my $user = "root";
my $password = "";

my $dbh = DBI->connect($dsn, $user, $password,
    { RaiseError => 1, PrintError => 0, AutoCommit => 1 })
    or die "Database connection failed: $DBI::errstr\n";

my $create = qq{
    CREATE TABLE IF NOT EXISTS `$tablename` (
        experiment VARCHAR(20),
        time INT NOT NULL,
        chr VARCHAR(10),
        coord INT NOT NULL,
        Acount INT NOT NULL,
        Tcount INT NOT NULL,
        Ccount INT NOT NULL,
        Gcount INT NOT NULL,
        Ncount INT NOT NULL,
        totalcount INT NOT NULL,
        PRIMARY KEY (experiment, time, chr, coord)
    )
};
$dbh->do($create);

my $quoted_matrix = $dbh->quote($matrixfile);
$dbh->do(qq{
    LOAD DATA LOCAL INFILE $quoted_matrix INTO TABLE `$tablename`
    (experiment,time,chr,coord,Acount,Tcount,Ccount,Gcount,Ncount,totalcount)
});

$dbh->disconnect;
