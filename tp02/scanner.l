%{
    #include <string.h>
    #include"y.tab.h"

    char string_lexema[8000];

    /* padroes aritmeticos */

    /* padroes escopo */

    const int ABRE_PARENTESES  = 20;
    const int FECHA_PARENTESES = 21;
    const int ABRE_COLCHETE    = 22;
    const int FECHA_COLCHETE   = 23;
    const int ABRE_CHAVES      = 24;
    const int FECHA_CHAVES     = 25;

    /* padroes delimitadores */

    const int PONTO_E_VIRGULA = 30;
    const int VIRGULA         = 31;

    /* padroes operadores logicos */

    const int MAIOR_QUE   = 50;
    const int MENOR_QUE   = 51;
    const int IGUAL       = 52;
    const int DIFERENTE   = 53;
    const int AND         = 54;
    const int OR          = 55;
    const int MAIOR_IGUAL = 56;
    const int MENOR_IGUAL = 57;

    /* padroes atribuicao, tipagem e acesso a atributos de classe */

    const int ATRIBUICAO  = 60;
    const int DOIS_PONTOS = 61;
    const int PONTO       = 62;

    /* padroes palavras reservadas de logica */
    
    const int IF    = 70;
    const int THEN  = 71;
    const int ELSE  = 72;

    /* padroes palavras reservadas loop */

    const int WHILE = 80;
    const int DO    = 81;
    const int FOR   = 82;
    const int TO    = 83;
    const int BREAK = 84;

    /* padroes palavras reservadas gerais */

    const int LET      = 90;
    const int IN       = 91;
    const int END      = 92;
    const int VAR      = 93;
    const int FUNCTION = 94;
    const int ARRAY    = 95;
    const int OF       = 96;
    const int TYPE     = 97;
    const int NIL      = 98;

    /* string constante */

    const int STRING_CONSTANTE   = 100;

    /* padroes nao constantes */

    const int VARIAVEL           = 41;
%}

%x STRING COMENTARIO

%%

 /*
 ---------------------------------------------------------------
 ------------------------ TAG INITIAL --------------------------
 ---------------------------------------------------------------
 */

 /* padroes aritmeticos */

<INITIAL>"+" {return MAIS;}
<INITIAL>"-" {return MENOS;}
<INITIAL>"*" {return MULTIPLICACAO;}
<INITIAL>"/" {return DIVISAO;}

 /* padroes escopo */

<INITIAL>"{"    {return ABRE_CHAVES;}
<INITIAL>"}"    {return FECHA_CHAVES;}
<INITIAL>"["    {return ABRE_COLCHETE;}
<INITIAL>"]"    {return FECHA_COLCHETE;}
<INITIAL>"("    {return ABRE_PARENTESES;}
<INITIAL>")"    {return FECHA_PARENTESES;}

 /* padroes delimitadores */

<INITIAL>";"    {return PONTO_E_VIRGULA;}
<INITIAL>","    {return VIRGULA;}

 /* padroes operadores logicos */

<INITIAL>">"    {return MAIOR_QUE;}
<INITIAL>"<"    {return MENOR_QUE;}
<INITIAL>"="    {return IGUAL;}
<INITIAL>"<>"   {return DIFERENTE;}
<INITIAL>"&"    {return AND;}
<INITIAL>"|"    {return OR;}
<INITIAL>">="   {return MAIOR_IGUAL;}
<INITIAL>"<="   {return MENOR_IGUAL;}

 /* padroes atribuicao, tipagem e acesso a atributos de classe */

<INITIAL>":="   {return ATRIBUICAO;}
<INITIAL>":"   {return DOIS_PONTOS;}
<INITIAL>"."   {return PONTO;}

 /* padroes palavras reservadas de logica */

<INITIAL>"if"   {return IF;}
<INITIAL>"then" {return THEN;}
<INITIAL>"else" {return ELSE;}

 /* padroes palavras reservadas loop */

<INITIAL>"while"   {return WHILE;}
<INITIAL>"do"      {return DO;}
<INITIAL>"for"     {return FOR;}
<INITIAL>"to"      {return TO;}
<INITIAL>"break"   {return BREAK;}

 /* padroes palavras reservadas gerais */

<INITIAL>"let"      {return LET;}
<INITIAL>"in"       {return IN;}
<INITIAL>"end"      {return END;}
<INITIAL>"var"      {return VAR;}
<INITIAL>"function" {return FUNCTION;}
<INITIAL>"array"    {return ARRAY;}
<INITIAL>"of"       {return OF;}
<INITIAL>"type"     {return TYPE;}
<INITIAL>"nil"      {return NIL;}

 /* inicio de uma string constante */

<INITIAL>"\"" { BEGIN(STRING); string_lexema[0] = '\0'; strcat(string_lexema,"\"");}

 /* inicio de um comentario */

<INITIAL>"/*" { BEGIN(COMENTARIO);}

 /* padroes nao constantes */

<INITIAL>[a-zA-Z][0-9a-zA-Z_]* {return VARIAVEL;}
<INITIAL>[0-9]+                {return NUMERO;}

 /*
 ---------------------------------------------------------------
 ------------------------ TAG STRING ---------------------------
 ---------------------------------------------------------------
 */

 /* montando a string constante */

<STRING>"\""        {BEGIN(INITIAL); strcat(string_lexema,"\""); yytext=string_lexema; return STRING_CONSTANTE;}
<STRING>[0-9a-zA-Z ]+               {strcat(string_lexema, yytext);}
<STRING>"\t"                        {strcat(string_lexema, yytext);}
<STRING>"\\n"                       {strcat(string_lexema, yytext);}
<STRING>[().;=:?!#$%&*+,-/<>@^_`|~] {strcat(string_lexema, yytext);}
<STRING>"]"                         {strcat(string_lexema, yytext);}
<STRING>"["                         {strcat(string_lexema, yytext);}
<STRING>"{"                         {strcat(string_lexema, yytext);}
<STRING>"}"                         {strcat(string_lexema, yytext);}
<STRING>"\'"                        {strcat(string_lexema, yytext);}

 /* montando o comentario */

<COMENTARIO>"*/"             {BEGIN(INITIAL);}
<COMENTARIO>[0-9a-zA-Z ]+               {}
<COMENTARIO>[().;=:?!#$%&*+,-/<>@^_`|~] {}
<COMENTARIO>"]"                         {}
<COMENTARIO>"["                         {}
<COMENTARIO>"{"                         {}
<COMENTARIO>"}"                         {}
<COMENTARIO>"\t"                        {}
<COMENTARIO>"\\n"                       {}
<COMENTARIO>"\n"                        {}
<COMENTARIO>"\""                        {}
<COMENTARIO>"\'"                        {}

 /*
 ---------------------------------------------------------------
 ------------------------ SEM TAG ------------------------------
 ---------------------------------------------------------------
 */

" " {}
"\n" {}
"\t" {}
%%

int yywrap() {
    return 1;
}

// int main(int argc, char** argv)
// {
//     int ntoken = yylex();

// 	while(ntoken) {
// 		printf("Token: %d  Lexema: %s\n", ntoken, yytext);

// 		ntoken = yylex();
// 	}
// }