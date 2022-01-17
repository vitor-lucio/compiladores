%{
    #include <string.h>
    #include"y.tab.h"

    char string_lexema[8000];
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
<INITIAL>[0-9]+                {yylval.valor_constante = yytext; return NUMERO;}

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