package CQL::Token;

use strict;
use warnings;
use base qw( Exporter );

=head1 NAME

CQL::Token - class for token objects returned by CQL::Lexer

=head1 SYNOPSIS

    my $token = $lexer->nextToken();
    
    if ( $token->type() == CQL_WORD ) { 
        print "the token is a word with value=", $token->string(), "\n";
    }

=head1 DESCRIPTION

Ordinarily you won't really care about the tokens returned by the 
CQL::Lexer since the lexer is used behind the scenes by CQL::Parser.

=head1 METHODS

=head2 new()

    my $token = CQL::Token->new( '=' );

=cut

## CQL keyword types
use constant CQL_LT        => 100;      ## The "<" relation
use constant CQL_GT        => 101;      ## The ">" relation
use constant CQL_EQ        => 102;      ## The "=" relation
use constant CQL_LE        => 103;	## The "<=" relation
use constant CQL_GE        => 104;	## The ">=" relation
use constant CQL_NE        => 105;	## The "<>" relation
use constant CQL_AND       => 106;	## The "and" boolean
use constant CQL_OR        => 107;	## The "or" boolean
use constant CQL_NOT       => 108;	## The "not" boolean
use constant CQL_PROX      => 109;	## The "prox" boolean
use constant CQL_ANY       => 110;	## The "any" relation
use constant CQL_ALL       => 111;	## The "all" relation
use constant CQL_EXACT     => 112;	## The "exact" relation
use constant CQL_PWORD     => 113;	## The "word" proximity unit
use constant CQL_SENTENCE  => 114;	## The "sentence" proximity unit
use constant CQL_PARAGRAPH => 115;	## The "paragraph" proximity unit
use constant CQL_ELEMENT   => 116;	## The "element" proximity unit
use constant CQL_ORDERED   => 117;	## The "ordered" proximity ordering
use constant CQL_UNORDERED => 118;	## The "unordered" proximity ordering
use constant CQL_RELEVANT  => 119;	## The "relevant" relation modifier
use constant CQL_FUZZY     => 120;	## The "fuzzy" relation modifier
use constant CQL_STEM      => 121;	## The "stem" relation modifier
use constant CQL_SCR       => 122;	## The server choice relation
use constant CQL_PHONETIC  => 123;	## The "phonetic" relation modifier
use constant CQL_WORD      => 124;      ## A general word (not an operator) 
use constant CQL_LPAREN    => 125;      ## A left paren
use constant CQL_RPAREN    => 126;      ## A right paren
use constant CQL_EOF       => 127;      ## End of query
use constant CQL_MODIFIER  => 128;      ## Start of modifier '/'

## lookup table for easily determining token type
our %lookupTable = (
    '<'          => CQL_LT,
    '>'          => CQL_GT,
    '='          => CQL_EQ,
    '<='         => CQL_LE,
    '>='         => CQL_GE,
    '<>'         => CQL_NE,
    'and'        => CQL_AND,
    'or'         => CQL_OR,
    'not'        => CQL_NOT,
    'prox'       => CQL_PROX,
    'any'        => CQL_ANY,
    'all'        => CQL_ALL,
    'exact'      => CQL_EXACT,
    'word'       => CQL_PWORD,
    'sentence'   => CQL_SENTENCE,
    'paragraph'  => CQL_PARAGRAPH,
    'element'    => CQL_ELEMENT,
    'ordered'    => CQL_ORDERED,
    'unordered'  => CQL_UNORDERED,
    'relevant'   => CQL_RELEVANT,
    'fuzzy'      => CQL_FUZZY,
    'stem'       => CQL_STEM,
    'phonetic'   => CQL_PHONETIC,
    '('          => CQL_LPAREN,
    ')'          => CQL_RPAREN,
    '/'          => CQL_MODIFIER,
    ''           => CQL_EOF,
);

## constants available for folks to use when looking at 
## token types

our @EXPORT = qw(
    CQL_LT CQL_GT CQL_EQ CQL_LE CQL_GE CQL_NE CQL_AND CQL_OR CQL_NOT 
    CQL_PROX CQL_ANY CQL_ALL CQL_EXACT CQL_PWORD CQL_SENTENCE CQL_PARAGRAPH
    CQL_ELEMENT CQL_ORDERED CQL_UNORDERED CQL_RELEVANT CQL_FUZZY
    CQL_STEM CQL_SCR CQL_PHONETIC CQL_RPAREN CQL_LPAREN
    CQL_WORD CQL_PHRASE CQL_EOF CQL_MODIFIER
);

=head2 new()

=cut

sub new {
    my ($class,$string) = @_;
    my $type;

    # see if it's a reserved word, which are case insensitive
    my $normalString = lc($string);
    if ( exists($lookupTable{$normalString}) ) {
        $string = $normalString;
        $type = $lookupTable{$normalString};
    }
    else {
        $type = CQL_WORD;
        $string =~ s/"//g; # remove quotes if present
    }
    return bless { string=>$string, type=>$type }, ref($class) || $class;
}

=head2 getType()

Returns the token type which will be availble as one of the constants
that CQL::Token exports. See internals for a list of available constants.

=cut

sub getType { return shift->{type}; }

=head2 getString()

Retruns the string equivalent of the token. Particularly useful when
you only know it's a CQL_WORD.

=cut

sub getString { return shift->{string}; }

1;
