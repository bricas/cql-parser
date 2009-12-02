use ExtUtils::MakeMaker;
use strict;
use warnings;

## create the Makefile
WriteMakefile(
    'NAME'              => 'CQL-Parser',
    'DISTNAME'          => 'CQL-Parser',
    'ABSTRACT'          => 'Common Query Language Parser',
    'VERSION_FROM'      => 'lib/CQL/Parser.pm',
    (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
    'PMLIBDIRS'         => [ qw( lib/ ) ],
    'AUTHOR'            => 'Ed Summers <ehs@pobox.com>',
    'PREREQ_PM'         => { 
                            'String::Tokenizer' => '0.05',
                            'Test::Exception'   => '0.21',
                            'Clone'             => '0.15',
                            'Class::Accessor'   => '0.1'
                           },
);
