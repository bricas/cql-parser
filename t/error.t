use strict;
use warnings;
use Test::More qw( no_plan );
use Test::Exception;

use_ok( 'CQL::Parser' );
my $parser = CQL::Parser->new();

throws_ok
    { $parser->parse( 'foo and' ) }
    qr/missing term/,
    'missing term';

## TODO: should add more errors here

