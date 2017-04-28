# sloth
Sloth lexer and parser

Instructions:

Download and install the latest version of flex from http://flex.sourceforge.net/

Download and install the latest version of Bison from https://www.gnu.org/software/bison/

Run the following commands:

    flex sloth.lex
    bison parser.y
    gcc parser.tab.c lex.yy.c

Finally, run the program with a sloth file as it's argument. For example:

    ./a.out fact.sl
