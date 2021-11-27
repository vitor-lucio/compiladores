%{
    #include <stdio.h>
    #include"lex.yy.c"
    
    void yyerror(const char *s);
    int yylex();
    int yywrap();
%}

%token NUMERO
%left MAIS MENOS
%left MULTIPLICACAO DIVISAO

%start exp_soma_subtracao_linha

%%
exp_soma_subtracao_linha: exp_soma_subtracao

exp_soma_subtracao: exp_soma_subtracao MAIS exp_mult_div
    | exp_soma_subtracao MENOS exp_mult_div
    | exp_mult_div

exp_mult_div: exp_mult_div MULTIPLICACAO valor_final
    | exp_mult_div DIVISAO valor_final
    | valor_final

valor_final: '(' exp_soma_subtracao ')'
    | NUMERO

%%

int main() {
    if (!yyparse())
        printf("Analise sintatica OK!\n");


    return 0;
}

void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}