%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include"lex.yy.c"
    
    void yyerror(const char *s);
    int yylex();
    int yywrap();
/*
////////////////////////////////////////////////////////////////////////////////
    Constantes
////////////////////////////////////////////////////////////////////////////////
*/

/* 
Parametros, a serem usados dentro do codigo intermediario,
para indicar locais onde precisamos inserir outro codigo intermediario, dentro de uma string */
char PARAMETRO1_CODIGO_INTERMEDIARIO[] = "$parametro1";
char PARAMETRO2_CODIGO_INTERMEDIARIO[] = "$parametro2";

/*
////////////////////////////////////////////////////////////////////////////////
    Estrutura do codigo intermediario final
////////////////////////////////////////////////////////////////////////////////
*/

char* codigo_intermediario_final;

/*
////////////////////////////////////////////////////////////////////////////////
    Estrutura da arvore
////////////////////////////////////////////////////////////////////////////////
*/
    struct node {
		char* codigo_intermediario;
        struct node* node_filho1;
        struct node* node_filho2;
        struct node* node_filho3;
	};

    struct node* raiz_da_arvore; /* raiz da arvore */
    int arvore_inicializada = 0; /* variavel que indica se a arvore foi inicializada (valor = 1) ou nao (valor = 0)  */


/*
////////////////////////////////////////////////////////////////////////////////
    Funcoes de construcao das strings de codigo intermediario
////////////////////////////////////////////////////////////////////////////////
*/

    char* constroi_codigo_intermediario_const(char* valor_constante){

        char* codigo_intermediario = (char*) malloc(strlen(valor_constante) + 7 + 1);
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "CONST(");
        strcat(codigo_intermediario, valor_constante);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_binop(char* tipo_operacao){

        char* codigo_intermediario = (char*) malloc(
                                                        strlen(tipo_operacao) 
                                                        + strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + 9 /* tamanho de: binop(,,) */ 
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "binop(");
        strcat(codigo_intermediario, tipo_operacao);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

/*
////////////////////////////////////////////////////////////////////////////////
    Funcoes da arvore
////////////////////////////////////////////////////////////////////////////////
*/

    int inicializa_arvore(struct node* node_raiz_candidato){
        if(arvore_inicializada == 1){ /* se arvore ja esta inicializada a funcao nao tem que fazer nada */
            return 1;
        }

        if(!node_raiz_candidato){ /* verifica se o node candidato e nulo */
            printf("Este node nao pode ser a raiz da arvore");
            return 0;
        }

        /* 
            A raiz da arvore recebe o endereco do node candidato,
            iniciando assim a arvore.

            A variavel global "arvore_inicializada" recebe 1, indicando que a arvore
            ja foi inicializada
        */
        raiz_da_arvore = node_raiz_candidato;
        arvore_inicializada = 1;
        return 1;
    }

    struct node* inicializa_node(struct node* node_filho1, struct node *node_filho2, struct node *node_filho3, char* codigo_intermediario) {
        struct node* novo_node = (struct node*) malloc(sizeof(struct node));
        
        char* copia_codigo_intermediario = (char*) malloc(strlen(codigo_intermediario)+1); /* Foi feita uma copia para evitar que o novo node aponte para a mesma memoria do parametro "codigo_intermediario" */
        strcpy(copia_codigo_intermediario, codigo_intermediario);
        
        novo_node->node_filho1 = node_filho1;
        novo_node->node_filho2 = node_filho2;
        novo_node->node_filho3 = node_filho3;
        novo_node->codigo_intermediario = copia_codigo_intermediario;
        return novo_node;
    }

/*
////////////////////////////////////////////////////////////////////////////////
    Funcoes de montagem do codigo intermediario final
////////////////////////////////////////////////////////////////////////////////
*/
    /*Esta funcao veio deste site https://www.geeksforgeeks.org/c-program-replace-word-text-another-given-word/ */
    char* replaceWord(char* s, char* oldW,
                  char* newW)
    {
        char* result;
        int i, cnt = 0;
        int newWlen = strlen(newW);
        int oldWlen = strlen(oldW);
    
        // Counting the number of times old word
        // occur in the string
        for (i = 0; s[i] != '\0'; i++) {
            if (strstr(&s[i], oldW) == &s[i]) {
                cnt++;
    
                // Jumping to index after the old word.
                i += oldWlen - 1;
            }
        }
    
        // Making new string of enough length
        result = (char*)malloc(i + cnt * (newWlen - oldWlen) + 1);
    
        i = 0;
        while (*s) {
            // compare the substring with the result
            if (strstr(s, oldW) == s) {
                strcpy(&result[i], newW);
                i += newWlen;
                s += oldWlen;
            }
            else
                result[i++] = *s++;
        }
    
        result[i] = '\0';
        return result;
    }

    /* Substitui o parametro ("nome_do_parametro") no codigo intermediario do node pelo "codigo_intermediario" passado como parametro */
    void substitui_parametro_por_codigo_intermediario_e_atribui_ao_node(struct node* node, char* nome_do_parametro, char* codigo_intermediario){
        char* codigo_intermediario_da_sub_arvore_com_parametro = replaceWord(
                                                                                node->codigo_intermediario, 
                                                                                nome_do_parametro,
                                                                                codigo_intermediario
                                                                            );

        free(node->codigo_intermediario);
        node->codigo_intermediario = codigo_intermediario_da_sub_arvore_com_parametro;
    }

    char* monta_codigo_intermediario_da_arvore(struct node* sub_arvore){
        if(sub_arvore->node_filho1){
            char* codigo_intermediario_do_node_filho = monta_codigo_intermediario_da_arvore(sub_arvore->node_filho1);

            substitui_parametro_por_codigo_intermediario_e_atribui_ao_node(sub_arvore, PARAMETRO1_CODIGO_INTERMEDIARIO, codigo_intermediario_do_node_filho);
            free(codigo_intermediario_do_node_filho);
        }

        if(sub_arvore->node_filho2){
            char* codigo_intermediario_do_node_filho = monta_codigo_intermediario_da_arvore(sub_arvore->node_filho2);

            substitui_parametro_por_codigo_intermediario_e_atribui_ao_node(sub_arvore, PARAMETRO2_CODIGO_INTERMEDIARIO, codigo_intermediario_do_node_filho);
            free(codigo_intermediario_do_node_filho);
        }
        
        /* Foi feita uma copia para evitar que outros ponteiros de char apontem para sub_arvore->codigo_intermediario,
           facilitando a interpretacao da memoria usada e permitindo o uso de free() para desalocar memoria nao usada
           e evitar erros inesperados */
        char* copia_codigo_intermediario = (char*) malloc(strlen(sub_arvore->codigo_intermediario)+1); 
        strcpy(copia_codigo_intermediario, sub_arvore->codigo_intermediario);
        return copia_codigo_intermediario;
    }

%}

%union { 
	struct node_da_arvore {
		struct node* node;
	} node_da_arvore;

    char* valor_constante;
} 
 
%token <valor_constante> NUMERO STRING_CONSTANTE NIL BREAK LET IN END FUNCTION TYPE VAR ARRAY DOIS_PONTOS VIRGULA PONTO_E_VIRGULA PONTO ABRE_CHAVES FECHA_CHAVES ABRE_COLCHETE FECHA_COLCHETE ABRE_PARENTESES FECHA_PARENTESES
%nonassoc WHILE IF FOR TO ATRIBUICAO VARIAVEL
%nonassoc THEN
%nonassoc ELSE DO OF
%left OR
%left AND
%left MAIOR_QUE MENOR_QUE IGUAL DIFERENTE MAIOR_IGUAL MENOR_IGUAL
%left <valor_constante> MAIS MENOS
%left MULTIPLICACAO DIVISAO

%type <node_da_arvore> exp type_id idexps l_value expseq expseq1 args args1 tyfields tyfields1 ty tydec vardec fundec decs dec

%start exp

%%
exp:  exp MAIS exp              {
                                    $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                    printf("%s\n", $$.node->codigo_intermediario);   
                                    printf("exp -> exp + exp\n"); 
                                } /* BINOP(MAIS, exp, exp) */
    | exp MENOS exp             { printf("exp -> exp - exp\n"); } /* BINOP(MENOS, exp, exp) */
    | exp MULTIPLICACAO exp     { printf("exp -> exp * exp\n"); } /* BINOP(MULTIPLICACAO, exp, exp) */
    | exp DIVISAO exp           { printf("exp -> exp / exp\n"); } /* BINOP(DIVISAO, exp, exp) */

    | MENOS exp                 { printf("exp -> - exp\n"); } /* CONST(- exp) */

    | NUMERO                    {
                                    $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_const($1));
                                    inicializa_arvore($$.node);
                                    printf("%s\n", $$.node->codigo_intermediario);   
                                    printf("exp -> num\n"); 
                                } /* CONST(NUMERO) */
    | STRING_CONSTANTE          { printf("exp -> string\n"); } /* 'STRING_CONSTANTE' */
    | NIL                       { printf("exp -> nil\n"); } /* NIL */

    | exp IGUAL exp             { printf("exp -> exp = exp\n"); } /* BINOP(IGUAL, exp, exp) */
    | exp DIFERENTE exp         { printf("exp -> exp <> exp\n"); } /* BINOP(DIFERENTE, exp, exp) */   
    | exp MENOR_QUE exp         { printf("exp -> exp < exp\n"); } /* BINOP(MENOR_QUE, exp, exp) */
    | exp MAIOR_QUE exp         { printf("exp -> exp > exp\n"); } /* BINOP(MAIOR_QUE, exp, exp) */
    | exp MENOR_IGUAL exp       { printf("exp -> exp <= exp\n"); } /* BINOP(MENOR_IGUAL, exp, exp) */
    | exp MAIOR_IGUAL exp       { printf("exp -> exp >= exp\n"); } /* BINOP(MAIOR_IGUAL, exp, exp) */
    | exp AND exp               { printf("exp -> exp & exp\n"); } /* BINOP(AND, exp, exp) */
    | exp OR exp                { printf("exp -> exp | exp\n"); } /* BINOP(OR, exp, exp) */

    | IF exp THEN exp ELSE exp  { printf("exp -> if exp then exp else exp\n"); } /* CJUMP(exp1.op, exp1.exp1, exp1.exp2, Labelexp2, Labelexp3) */
    | IF exp THEN exp           { printf("exp -> if exp then exp\n"); } /* CJUMP(exp1.op, exp1.exp1, exp1.exp2, Labelexp2, enderecoDoCodigoAposIf) */
    | WHILE exp DO exp          { printf("exp -> while exp do exp\n"); } /* CJUMP(exp1.op, exp1.exp1, exp1.exp2, Labelexp2, enderecoDoCodigoAposWhile) */

    | FOR VARIAVEL ATRIBUICAO exp TO exp DO exp { printf("exp -> for id := exp to exp do exp\n"); } /* CJUMP(MENOR_IGUAL, exp1.exp1, exp1.exp2, Labelexp2, enderecoDoCodigoAposWhile) */
    | BREAK                                     { printf("exp -> break\n"); } /* JUMP(labelAnteriorAoDoLabelQueExecutouBreak + proximoComandoDoLabelQueExecutouBreak, labelAnteriorAoDoLabelQueExecutouBreak + proximoComandoDoLabelQueExecutouBreak) */

    | type_id ABRE_CHAVES VARIAVEL IGUAL exp idexps FECHA_CHAVES    { printf("exp -> type-id { id = exp idexps }\n"); }
    | type_id ABRE_COLCHETE exp FECHA_COLCHETE OF exp               { printf("exp -> type-id [ exp ] of exp\n"); }

    | l_value ATRIBUICAO exp    { printf("exp -> l-value := exp\n"); }
    | type_id ATRIBUICAO exp    { printf("exp -> type-id := exp\n"); }

    | type_id                   { printf("exp -> type-id\n"); }
    | l_value                   { printf("exp -> l-value\n"); }

    | ABRE_PARENTESES expseq FECHA_PARENTESES           { printf("exp -> ( expseq )\n"); } /* Nenhum código intermediário neste nó */
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

expseq: exp expseq1                             { printf("expseq -> exp expseq1\n"); } /* Nenhum código intermediário neste nó */
    |                                           { printf("expseq -> \n"); } /* Nenhum código intermediário neste nó */
    ;

expseq1: PONTO_E_VIRGULA exp expseq1            { printf("expseq1 -> ; exp expseq1\n"); } /* Nenhum código intermediário neste nó */
    |                                           { printf("expseq1 -> \n"); } /* Nenhum código intermediário neste nó */
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