%{
    #include <string.h>
    #include"y.tab.h"

    char string_lexema[8000];
    struct simbolo* inicializa_simbolo(char* nome, char* tipo, char* valor, char* classe, char* numero_parametros, char* endereco);
    void adiciona_simbolo(struct simbolo *s);
    void imprime_tabela_simbolos();
%}

%x STRING COMENTARIO

%%

 /*
 ---------------------------------------------------------------
 ------------------------ TAG INITIAL --------------------------
 ---------------------------------------------------------------
 */

 /* padroes aritmeticos */

<INITIAL>"+" {yylval.valor_constante = "MAIS"; return MAIS;}
<INITIAL>"-" {yylval.valor_constante = "MENOS"; return MENOS;}
<INITIAL>"*" {yylval.valor_constante = "MULTIPLICACAO"; return MULTIPLICACAO;}
<INITIAL>"/" {yylval.valor_constante = "DIVISAO"; return DIVISAO;}

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

<INITIAL>">"    {yylval.valor_constante = "MAIOR_QUE"; return MAIOR_QUE;}
<INITIAL>"<"    {yylval.valor_constante = "MENOR_QUE"; return MENOR_QUE;}
<INITIAL>"="    {yylval.valor_constante = "IGUAL"; return IGUAL;}
<INITIAL>"<>"   {yylval.valor_constante = "DIFERENTE"; return DIFERENTE;}
<INITIAL>"&"    {yylval.valor_constante = "AND"; return AND;}
<INITIAL>"|"    {yylval.valor_constante = "OR"; return OR;}
<INITIAL>">="   {yylval.valor_constante = "MAIOR_IGUAL"; return MAIOR_IGUAL;}
<INITIAL>"<="   {yylval.valor_constante = "MENOR_IGUAL"; return MENOR_IGUAL;}

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

<INITIAL>[a-zA-Z][0-9a-zA-Z_]* {
                                    char* aux = (char*) malloc (strlen(yytext)+1);
                                    strcpy(aux, yytext);
                                    yylval.valor_constante = aux; 
                                    
                                    struct simbolo* novo_simbolo = inicializa_simbolo(yytext, "?", "?", "?", "?", "?");
                                    adiciona_simbolo(novo_simbolo);
                                    printf("VIM PELO LEXER!\n");
                                    imprime_tabela_simbolos();
                                    
                                    return VARIAVEL;
                                }
<INITIAL>[0-9]+                {
                                    char* aux = (char*) malloc (strlen(yytext)+1);
                                    strcpy(aux, yytext);
                                    yylval.valor_constante = aux; 
                                    return NUMERO;
                                }

 /*
 ---------------------------------------------------------------
 ------------------------ TAG STRING ---------------------------
 ---------------------------------------------------------------
 */

 /* montando a string constante */

<STRING>"\""        {BEGIN(INITIAL); strcat(string_lexema,"\""); yytext=string_lexema; yylval.valor_constante = yytext; return STRING_CONSTANTE;}
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