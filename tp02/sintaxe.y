%{
    #include <stdio.h>
    #include"lex.yy.c"
    
    void yyerror(const char *s);
    int yylex();
    int yywrap();
%}
 
%token NUMERO STRING_CONSTANTE NIL BREAK LET IN END FUNCTION TYPE VAR ARRAY DOIS_PONTOS VIRGULA PONTO_E_VIRGULA PONTO ABRE_CHAVES FECHA_CHAVES ABRE_COLCHETE FECHA_COLCHETE ABRE_PARENTESES FECHA_PARENTESES
%nonassoc WHILE IF FOR TO ATRIBUICAO VARIAVEL
%nonassoc THEN
%nonassoc ELSE DO OF
%left OR
%left AND
%left MAIOR_QUE MENOR_QUE IGUAL DIFERENTE MAIOR_IGUAL MENOR_IGUAL
%left MAIS MENOS
%left MULTIPLICACAO DIVISAO

%start exp

%%
exp:  exp MAIS exp 
    | exp MENOS exp 
    | exp MULTIPLICACAO exp 
    | exp DIVISAO exp

    | MENOS exp

    | NUMERO
    | STRING_CONSTANTE
    | NIL

    | exp IGUAL exp 
    | exp DIFERENTE exp
    | exp MENOR_QUE exp 
    | exp MAIOR_QUE exp 
    | exp MENOR_IGUAL exp 
    | exp MAIOR_IGUAL exp
    | exp AND exp 
    | exp OR exp

    | IF exp THEN exp ELSE exp
    | IF exp THEN exp
    | WHILE exp DO exp

    | FOR VARIAVEL ATRIBUICAO exp TO exp DO exp
    | BREAK

    | type_id ABRE_CHAVES VARIAVEL IGUAL exp idexps FECHA_CHAVES
    | type_id ABRE_COLCHETE exp FECHA_COLCHETE OF exp

    | l_value ATRIBUICAO exp
    | type_id ATRIBUICAO exp

    | type_id
    | l_value

    | ABRE_PARENTESES expseq FECHA_PARENTESES
    | VARIAVEL ABRE_PARENTESES args FECHA_PARENTESES

    | LET decs IN expseq END
    ;  

type_id: VARIAVEL
    ;

idexps: VIRGULA VARIAVEL IGUAL exp idexps 
    |
    ;

l_value: type_id PONTO VARIAVEL 
    | l_value PONTO VARIAVEL
    | type_id ABRE_COLCHETE exp FECHA_COLCHETE
    | l_value ABRE_COLCHETE exp FECHA_COLCHETE
    ;

expseq: exp expseq1
    |
    ;

expseq1: PONTO_E_VIRGULA exp expseq1
    | 
    ;

args: exp args1
    |
    ;

args1: VIRGULA exp args1
    |
    ;

tyfields: VARIAVEL DOIS_PONTOS type_id tyfields1
    |
    ;

tyfields1: VIRGULA VARIAVEL DOIS_PONTOS type_id tyfields1
    |
    ;

ty: VARIAVEL 
    | ABRE_CHAVES VARIAVEL DOIS_PONTOS type_id tyfields1 FECHA_CHAVES 
    | ARRAY OF VARIAVEL
    ;

tydec: TYPE VARIAVEL IGUAL ty
    ;

vardec: VAR VARIAVEL ATRIBUICAO exp 
    | VAR VARIAVEL DOIS_PONTOS type_id ATRIBUICAO exp
    ;

fundec: FUNCTION VARIAVEL ABRE_PARENTESES tyfields FECHA_PARENTESES IGUAL exp
    | FUNCTION VARIAVEL ABRE_PARENTESES tyfields FECHA_PARENTESES DOIS_PONTOS type_id IGUAL exp
    ;

decs: dec decs 
    | 
    ;

dec: tydec 
    | vardec 
    | fundec
    ;

%%

int main() {
    if (!yyparse())
        printf("Analise sintatica OK!\n");

    return 0;
}

void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}