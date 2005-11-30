use strict;
use warnings;
use Test::More tests => 33; 
use Test::Exception;

use_ok( 'CQL::Parser' );

my $parser = CQL::Parser->new();
isa_ok( $parser, 'CQL::Parser' );

## foo
my $root = $parser->parse( 'foo' );
is( $root->toCQL(), 'foo', 'foo' );
isa_ok( $root, 'CQL::TermNode' );

## "foo bar"
$root = $parser->parse( '"foo bar"' );
is( $root->toCQL(), '"foo bar"', '"foo bar"' );
isa_ok( $root, 'CQL::TermNode' );

## foo and bar
$root = $parser->parse( 'foo and bar' );
is( $root->toCQL(), '(foo) and (bar)', 'foo and bar' );
isa_ok( $root, 'CQL::AndNode' );

## foo bar
throws_ok 
    { $parser->parse('foo bar') } 
    qr/unknown first class relation: bar/, 
    'foo bar : unknown first class relation bar'; 

## (foo and bar)
$root = $parser->parse('(foo or bar) and bez' );
is( $root->toCQL(), '((foo) or (bar)) and (bez)','(foo or bar) and bez' );
isa_ok( $root, 'CQL::AndNode' );

## dc.title = foo
$root = $parser->parse('dc.title = foo');
is( $root->toCQL(), 'dc.title = foo', 'dc.title = foo' );
isa_ok( $root, 'CQL::TermNode' );

## dc.title=foo and dc.creator=bar
$root = $parser->parse('dc.title=foo and dc.creator=bar' );
is( $root->toCQL(), '(dc.title = foo) and (dc.creator = bar)', 
    'dc.title=foo and dc.creator=bar' );
isa_ok( $root, 'CQL::AndNode' );

## complete prox dinosaur
$root = $parser->parse( 'complete prox dinosaur' );
is( $root->toCQL(), '(complete) prox (dinosaur)', 'complete prox dinosaur' );
isa_ok( $root, 'CQL::ProxNode' );

## complete prox/<= dinosaur
$root = $parser->parse( 'complete prox/<= dinosaur' );
is( $root->toCQL(), '(complete) prox/<= (dinosaur)',
    'complete prox/<= dinosaur' );
isa_ok( $root, 'CQL::ProxNode' );

## complete prox/bogus dinosaur
throws_ok
    { $parser->parse( 'complete prox/bogus dinosaur') }
    qr/expected proximity relation got bogus/,
    'bad proximity relation';

## complete prox/<=/1 dinosaur
$root = $parser->parse( 'complete prox/<=/1 dinosaur');
is( $root->toCQL(), '(complete) prox/<=/1 (dinosaur)',
    'complete prox/<=/1 dinosaur' );
isa_ok( $root, 'CQL::ProxNode' );

## complete prox/<=/bogus dinosaur
throws_ok
    { $parser->parse( 'complete prox/<=/bogus dinosaur') }
    qr/expected proximity distance got bogus/,
    'bad proximity distance';

## complete prox/<=/1/word dinosaur
$root = $parser->parse( 'complete prox/<=/1/word dinosaur' );
is( $root->toCQL(), '(complete) prox/<=/1/word (dinosaur)',
    'complete prox/<=/1 dinosaur/word' );
isa_ok( $root, 'CQL::ProxNode' );

## complete prox/<=/1/bogus dinosaur
throws_ok
    { $parser->parse( 'complete prox/<=/bogus dinosaur') }
    qr/expected proximity distance got bogus/,
    'bad proximity distance';

## complete prox/<=/1/word/ordered dinosaur
$root = $parser->parse( 'complete prox/<=/1/word/ordered dinosaur' );
is( $root->toCQL(), '(complete) prox/<=/1/word/ordered (dinosaur)',
    'complete prox/<=/1 dinosaur/word/ordered' );
isa_ok( $root, 'CQL::ProxNode' );

## complete prox/<=/1/word/bogus dinosaur
throws_ok
    { $parser->parse( 'complete prox/<=/1/word/bogus dinosaur' ) }
    qr/expected proximity ordering got bogus/,
    'expected proximity ordering got bogus';

## some versions didn't handle <> 
$root = $parser->parse('dc.title <> app');
is( 'dc.title <> app', $root->toCQL(), '<> works' );

## foo oR bar  
$root = $parser->parse("foo oR bar");
is( '(foo) or (bar)', $root->toCQL(), 'keywords case insensitive' );

## prefix
$root = $parser->parse( 
    '>dc="http://zthes.z3950.org/cql/1.0" foo and bar' );
isa_ok( $root, 'CQL::PrefixNode' );
is( $root->toCQL(), '>dc="http://zthes.z3950.org/cql/1.0" ((foo) and (bar))',
    'toCQL()' );

