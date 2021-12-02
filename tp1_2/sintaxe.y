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
exp:  exp MAIS exp              { printf("exp -> exp + exp\n"); }
    | exp MENOS exp             { printf("exp -> exp - exp\n"); }
    | exp MULTIPLICACAO exp     { printf("exp -> exp * exp\n"); }
    | exp DIVISAO exp           { printf("exp -> exp / exp\n"); }

    | MENOS exp                 { printf("exp -> - exp\n"); }

    | NUMERO                    { printf("exp -> num\n"); }
    | STRING_CONSTANTE          { printf("exp -> string\n"); }
    | NIL                       { printf("exp -> nil\n"); }

    | exp IGUAL exp             { printf("exp -> exp = exp\n"); }
    | exp DIFERENTE exp         { printf("exp -> exp <> exp\n"); }   
    | exp MENOR_QUE exp         { printf("exp -> exp < exp\n"); }
    | exp MAIOR_QUE exp         { printf("exp -> exp > exp\n"); }
    | exp MENOR_IGUAL exp       { printf("exp -> exp <= exp\n"); }
    | exp MAIOR_IGUAL exp       { printf("exp -> exp >= exp\n"); }
    | exp AND exp               { printf("exp -> exp & exp\n"); }
    | exp OR exp                { printf("exp -> exp | exp\n"); }

    | IF exp THEN exp ELSE exp  { printf("exp -> if exp then exp else exp\n"); }
    | IF exp THEN exp           { printf("exp -> if exp then exp\n"); }
    | WHILE exp DO exp          { printf("exp -> while exp do exp\n"); }

    | FOR VARIAVEL ATRIBUICAO exp TO exp DO exp { printf("exp -> for id := exp to exp do exp\n"); }
    | BREAK                                     { printf("exp -> break\n"); }

    | type_id ABRE_CHAVES VARIAVEL IGUAL exp idexps FECHA_CHAVES    { printf("exp -> type-id { id = exp idexps }\n"); }
    | type_id ABRE_COLCHETE exp FECHA_COLCHETE OF exp               { printf("exp -> type-id [ exp ] of exp\n"); }

    | l_value ATRIBUICAO exp    { printf("exp -> l-value := exp\n"); }
    | type_id ATRIBUICAO exp    { printf("exp -> type-id := exp\n"); }

    | type_id                   { printf("exp -> type-id\n"); }
    | l_value                   { printf("exp -> l-value\n"); }

    | ABRE_PARENTESES expseq FECHA_PARENTESES           { printf("exp -> ( expseq )\n"); }
    | VARIAVEL ABRE_PARENTESES args FECHA_PARENTESES    { printf("exp -> id ( args )\n"); }

    | LET decs IN expseq END                            { printf("exp -> let decs in expseq end\n"); }
    ;  

type_id: VARIAVEL   { printf("type-id -> id\n"); }
    ;

idexps: VIRGULA VARIAVEL IGUAL exp idexps   { printf("idexps  -> , id = exp idexps\n"); }
    |                                       { printf("idexps -> \n"); }
    ;

l_value: type_id PONTO VARIAVEL                 { printf("l-value -> type-id . id\n"); }
    | l_value PONTO VARIAVEL                    { printf("l-value -> l-value . id\n"); }
    | type_id ABRE_COLCHETE exp FECHA_COLCHETE  { printf("l-value -> type-id [ exp ]\n"); }
    | l_value ABRE_COLCHETE exp FECHA_COLCHETE  { printf("l-value -> l-value [ exp ]\n"); }
    ;

expseq: exp expseq1                             { printf("expseq -> exp expseq1\n"); }
    |                                           { printf("expseq -> \n"); }
    ;

expseq1: PONTO_E_VIRGULA exp expseq1            { printf("expseq1 -> ; exp expseq1\n"); }
    |                                           { printf("expseq1 -> \n"); }
    ;

args: exp args1                                 { printf("args -> exp args1\n"); }
    |                                           { printf("args -> \n"); }
    ;

args1: VIRGULA exp args1                        { printf("args1 -> , exp args1\n"); }
    |                                           { printf("args1 -> \n"); }
    ;

tyfields: VARIAVEL DOIS_PONTOS type_id tyfields1    { printf("tyfields -> id : type-id tyfields1\n"); }
    |                                               { printf("tyfields -> \n"); }
    ;   

tyfields1: VIRGULA VARIAVEL DOIS_PONTOS type_id tyfields1   { printf("tyfields1 -> , id : type-id tyfields1\n"); }
    |                                                       { printf("tyfields1 -> \n"); }
    ;

ty: VARIAVEL                                                           { printf("ty -> id\n"); }
    | ABRE_CHAVES VARIAVEL DOIS_PONTOS type_id tyfields1 FECHA_CHAVES  { printf("ty -> { id : type-id tyfields1 }\n"); }
    | ARRAY OF VARIAVEL                                                { printf("ty -> array of id\n"); }
    ;

tydec: TYPE VARIAVEL IGUAL ty   { printf("tydec -> type id = ty\n"); }
    ;

vardec: VAR VARIAVEL ATRIBUICAO exp                     { printf("vardec -> var id := exp\n"); }
    | VAR VARIAVEL DOIS_PONTOS type_id ATRIBUICAO exp   { printf("vardec -> var id : type-id := exp\n"); }
    ;

fundec: FUNCTION VARIAVEL ABRE_PARENTESES tyfields FECHA_PARENTESES IGUAL exp   { printf("fundec -> function id ( tyfields ) = exp\n"); }
    | FUNCTION VARIAVEL ABRE_PARENTESES tyfields FECHA_PARENTESES DOIS_PONTOS type_id IGUAL exp { printf("fundec -> function id ( tyfields ) : type-id = exp\n"); }
    ;

decs: dec decs  { printf("decs -> dec decs\n"); }
    |           { printf("decs -> \n"); }
    ;

dec: tydec      { printf("dec -> tydec\n"); }
    | vardec    { printf("dec -> vardec\n"); }
    | fundec    { printf("dec -> fundec\n"); }
    ;

%%

void printCode(char* filename){
    printf("\n----------------------------------------\n\n");
    printf("CÓDIGO FONTE SUBMETIDO:\n\n");

    FILE *code = fopen(filename, "r" );
    char c;

    while ((c = getc(code)) != EOF){
        printf("%c", c);
    }

    printf("\n");
    fclose(code);
}

int main(int argc, char** argv) {
    printf("\nREGRAS UTILIZADAS:\n\n");

    yyin = fopen(argv[1], "r" );
    
    if (!yyparse()){
        printf("\n----------------------------------------\n\n");
        printf("RESULTADO:\n\nANALISE SINTATICA OK!\n");
    }
    
    printCode(argv[1]);

    return 0;
}

void yyerror(const char* msg) {
    printf("\n----------------------------------------\n\n");
    printf("RESULTADO:\n\nERRO DE SINTAXE!\n");
}