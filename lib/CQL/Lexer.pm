package CQL::Lexer;

use strict;
use warnings;
use String::Tokenizer;
use CQL::Token;

=head1 NAME

CQL::Lexer - a lexical analyzer for CQL

=head1 SYNOPSIS

    my $lexer = CQL::Lexer->new();
    $lexer->tokenize( 'foo and bar' );
    my @tokens = $lexer->getTokens();

=head1 DESCRIPTION

CQL::Lexer is lexical analyzer for a string of CQL. Once you've
got a CQL::Lexer object you can tokenize a CQL string into CQL::Token
objects. Ordinarily you'll never want to do this yourself since
CQL::Parser calls CQL::Lexer for you.

CQL::Lexer uses Stevan Little's lovely String::Tokenizer in the background,
and does a bit of analysis afterwards to handle some peculiarities of 
CQL: double quoted strings, <, <=, etc.

=head1 METHODS

=head2 new()

The constructor. 

=cut

sub new {
    my $class = shift;
    my $self = { 
        tokenizer   => String::Tokenizer->new(),
        tokens      => [],
        position    => 0,
    };
    return bless $self, ref($class) || $class;
}

=head2 tokenize()

Pass in a string of CQL to tokenize. This initializes the lexer with 
data so that you can retrieve tokens.

=cut

sub tokenize {
    my ( $self, $string ) = @_;

    ## extract the String::Tokenizer object we will use
    my $tokenizer = $self->{tokenizer};

    ## reset position parsing a new string of tokens
    $self->reset();

    ## delegate to String::Tokenizer for basic tokenization
    debug( "tokenizing: $string" );
    $tokenizer->tokenize( $string, '/<>=()"',
        String::Tokenizer->RETAIN_WHITESPACE );

    ## do a bit of lexical analysis on the results of basic
    debug( "lexical analysis on tokens" );
    my @tokens = _analyze( $tokenizer );
    $self->{tokens} = \@tokens;
}

=head2 getTokens()

Returns a list of all the tokens.

=cut

sub getTokens {
    my $self = shift;
    return @{ $self->{tokens} };
}

=head2 token() 

Returns the current token.

=cut

sub token {
    my $self = shift;
    return $self->{tokens}[ $self->{position} ];
}

=head2 nextToken()

Returns the next token, or undef if there are more tokens to retrieve
from the lexer.

=cut

sub nextToken {
    my $self = shift;
    ## if we haven't gone over the end of our token list
    ## return the token at our current position while
    ## incrementing the position.
    if ( $self->{position} < @{ $self->{tokens} } ) {
        my $token = $self->{tokens}[ $self->{position}++ ];
        return $token;
    }
    return CQL::Token->new( '' );
}

=head2 prevToken()

Returns the previous token, or undef if there are no tokens prior
to the current token.

=cut

sub prevToken {
    my $self = shift;
    ## if we're not at the start of our list of tokens
    ## return the one previous to our current position
    ## while decrementing our position.
    if ( $self->{position} > 0 ) {
        my $token = $self->{tokens}[ --$self->{position} ];
        return $token;
    }
    return CQL::Token->new( '' );
}

=head2 reset()

Resets the iterator to start reading tokens from the beginning.

=cut

sub reset {
    shift->{position} = 0;
}

sub _analyze { 
    my $tokenizer = shift;

    my $iterator = $tokenizer->iterator();
    my @tokens;
    while ( my $token = $iterator->nextToken() ) {

        ## <=
        if ( $token eq '<' and $iterator->lookAheadToken() eq '=' ) {
            push( @tokens, CQL::Token->new( '<=' ) );
            $iterator->nextToken();
        } 

        ## >=
        elsif ( $token eq '>' and $iterator->lookAheadToken() eq '=' ) {
            push( @tokens, CQL::Token->new( '>=' ) );
            $iterator->nextToken();
        }

        ## "quoted strings"
        elsif ( $token eq '"' ) {
            my $string = join( '', $iterator->collectTokensUntil( '"' ) );
            push( @tokens, CQL::Token->new( qq("$string") ) );
        }

        ## if it's just whitespace we can zap it
        elsif ( $token =~ / +/ ) { 
            ## ignore 
        }

        ## otherwise it's fine the way it is 
        else {
            push( @tokens, CQL::Token->new($token) );
        }

    }
    return @tokens;
}

sub debug {
    return unless $CQL::DEBUG;
    print STDERR 'CQL::Lexer: ', shift, "\n";
}

1;
