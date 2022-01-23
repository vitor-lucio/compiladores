%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include "lex.yy.c"
    // #include "table.h"
    
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
        char* tipo;
        char* valor;
	};

    struct node* raiz_da_arvore; /* raiz da arvore */


/*
////////////////////////////////////////////////////////////////////////////////
    Funcoes de construcao das strings de codigo intermediario
////////////////////////////////////////////////////////////////////////////////
*/

    char* constroi_codigo_intermediario_vazio(){

        char* codigo_intermediario = (char*) malloc(
                                                        1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_const(char* valor_constante){

        char* codigo_intermediario = (char*) malloc(
                                                        strlen(valor_constante) 
                                                        + 7 /* tamanho de: const() */
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
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

    char* constroi_codigo_intermediario_eseq(){

        char* codigo_intermediario = (char*) malloc(
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + 7 /* tamanho de: eseq(,) */ 
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "eseq(");
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

    int aponta_raiz_da_arvore(struct node* node_raiz_candidato){
        if(!node_raiz_candidato){ /* verifica se o node candidato e nulo */
            printf("Este node nao pode ser a raiz da arvore");
            return 0;
        }

        /* 
            A raiz da arvore recebe o endereco do node candidato,
            iniciando assim a arvore.
        */
        raiz_da_arvore = node_raiz_candidato;
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










    typedef struct simbolo{

        char* nome;
        char* tipo;
        char* classe;
        char* numero_parametros;
        char* endereco;    

        struct simbolo *next;
        
    }simbolo;

    typedef struct tabela{
        struct simbolo *primeiro_elemento;
    }tabela;

    struct tabela tabela_simbolos;


    struct simbolo *inicializa_simbolo(char* nome, char* tipo, char* classe, char* numero_parametros, char* endereco){
        struct simbolo* novo_simbolo = (struct simbolo*) malloc (sizeof(struct simbolo));
        
        char* aux = (char*) malloc (strlen(nome)+1); 
        strcpy(aux, nome);
        novo_simbolo->nome = aux;

        aux = (char*) malloc (strlen(tipo)+1); 
        strcpy(aux, tipo);
        novo_simbolo->tipo = aux;
        
        aux = (char*) malloc (strlen(classe)+1); 
        strcpy(aux, classe);
        novo_simbolo->classe = aux;
        
        aux = (char*) malloc (strlen(numero_parametros)+1); 
        strcpy(aux, numero_parametros);
        novo_simbolo->numero_parametros = aux;
        
        aux = (char*) malloc (strlen(endereco)+1); 
        strcpy(aux, endereco);
        novo_simbolo->endereco = aux;

        return novo_simbolo;
    }

    void inicializa_tabela_simbolos(){
        tabela_simbolos.primeiro_elemento = NULL;
    }

    void adiciona_simbolo(struct simbolo *s){
      
        if(!tabela_simbolos.primeiro_elemento){
            tabela_simbolos.primeiro_elemento = s;
            tabela_simbolos.primeiro_elemento->next = NULL;
        }else{
            struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
            
            while(iterador->next != NULL){
                iterador = iterador->next;
            }
            
            iterador->next = s;
            iterador->next->next = NULL;
        }
    }

    void imprime_tabela_simbolos(){
        struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
        
        while(iterador != NULL){
            printf("%s - %s, ", iterador->nome, iterador->tipo);
            iterador = iterador->next;
        }

        printf("\n");
    }

    /*
        Inicializações
    */
    
%}

%union { 
	struct node_da_arvore {
		struct node* node;
	} node_da_arvore;

    char* valor_constante;
} 

%token <valor_constante> NUMERO STRING_CONSTANTE NIL BREAK LET IN END FUNCTION TYPE VAR ARRAY DOIS_PONTOS VIRGULA PONTO_E_VIRGULA PONTO ABRE_CHAVES FECHA_CHAVES ABRE_COLCHETE FECHA_COLCHETE ABRE_PARENTESES FECHA_PARENTESES
%nonassoc <valor_constante> WHILE IF FOR TO ATRIBUICAO VARIAVEL
%nonassoc THEN
%nonassoc ELSE DO OF
%left <valor_constante> OR
%left <valor_constante> AND
%left <valor_constante> MAIOR_QUE MENOR_QUE IGUAL DIFERENTE MAIOR_IGUAL MENOR_IGUAL
%left <valor_constante> MAIS MENOS
%left <valor_constante> MULTIPLICACAO DIVISAO

%type <node_da_arvore> exp type_id idexps l_value expseq expseq1 args args1 tyfields tyfields1 ty tydec vardec fundec decs dec

%start exp

%%
exp:  exp MAIS exp              {
                                    $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                    
                                    if($$.node->node_filho1->tipo == "int" && $$.node->node_filho2->tipo == "int"){
                                        $$.node->tipo = $$.node->node_filho1->tipo; 
                                        printf("TIPO: %s\n", $$.node->tipo);
                                    }else{
                                        printf("ERRO!\n");
                                    }

                                    printf("%s\n", $$.node->codigo_intermediario);
                                    printf("node filho1: %s\n", $$.node->node_filho1->codigo_intermediario);
                                    printf("node filho2: %s\n", $$.node->node_filho2->codigo_intermediario);
                                    printf("exp -> exp + exp\n"); 

                                } /* BINOP(MAIS, exp, exp) */
    | exp MENOS exp             {
                                    $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                    printf("%s\n", $$.node->codigo_intermediario);
                                    printf("node filho1: %s\n", $$.node->node_filho1->codigo_intermediario);
                                    printf("node filho2: %s\n", $$.node->node_filho2->codigo_intermediario); 
                                    printf("exp -> exp - exp\n"); 
                                } /* BINOP(MENOS, exp, exp) */
    | exp MULTIPLICACAO exp     {
                                    $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                    printf("%s\n", $$.node->codigo_intermediario);
                                    printf("node filho1: %s\n", $$.node->node_filho1->codigo_intermediario);
                                    printf("node filho2: %s\n", $$.node->node_filho2->codigo_intermediario); 
                                    printf("exp -> exp * exp\n"); 
                                } /* BINOP(MULTIPLICACAO, exp, exp) */
    | exp DIVISAO exp           {
                                    $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                    printf("%s\n", $$.node->codigo_intermediario);
                                    printf("node filho1: %s\n", $$.node->node_filho1->codigo_intermediario);
                                    printf("node filho2: %s\n", $$.node->node_filho2->codigo_intermediario);  
                                    printf("exp -> exp / exp\n"); 
                                } /* BINOP(DIVISAO, exp, exp) */

    | MENOS exp                 { printf("exp -> - exp\n"); } /* CONST(- exp) */

    | NUMERO                    {
                                    $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_const($1));
                                    $$.node->tipo = "int";
                                    printf("%s\n", $$.node->codigo_intermediario);   
                                    printf("exp -> num\n");
                                } /* CONST(NUMERO) */
    | STRING_CONSTANTE          { 
                                    $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_const($1));
                                    $$.node->tipo = "string";
                                    printf("exp -> string\n"); 
                                } /* 'STRING_CONSTANTE' */
    | NIL                       { printf("exp -> nil\n"); } /* NIL */

    | exp IGUAL exp             {
                                    $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                    printf("%s\n", $$.node->codigo_intermediario);
                                    printf("node filho1: %s\n", $$.node->node_filho1->codigo_intermediario);
                                    printf("node filho2: %s\n", $$.node->node_filho2->codigo_intermediario);   
                                    printf("exp -> exp = exp\n"); 
                                } /* BINOP(IGUAL, exp, exp) */
    | exp DIFERENTE exp         {
                                    $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                    printf("%s\n", $$.node->codigo_intermediario);
                                    printf("node filho1: %s\n", $$.node->node_filho1->codigo_intermediario);
                                    printf("node filho2: %s\n", $$.node->node_filho2->codigo_intermediario);   
                                    printf("exp -> exp <> exp\n"); 
                                } /* BINOP(DIFERENTE, exp, exp) */   
    | exp MENOR_QUE exp         {
                                    $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                    printf("%s\n", $$.node->codigo_intermediario);
                                    printf("node filho1: %s\n", $$.node->node_filho1->codigo_intermediario);
                                    printf("node filho2: %s\n", $$.node->node_filho2->codigo_intermediario);   
                                    printf("exp -> exp < exp\n"); 
                                } /* BINOP(MENOR_QUE, exp, exp) */
    | exp MAIOR_QUE exp         {
                                    $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                    printf("%s\n", $$.node->codigo_intermediario);
                                    printf("node filho1: %s\n", $$.node->node_filho1->codigo_intermediario);
                                    printf("node filho2: %s\n", $$.node->node_filho2->codigo_intermediario);   
                                    printf("exp -> exp > exp\n"); 
                                } /* BINOP(MAIOR_QUE, exp, exp) */
    | exp MENOR_IGUAL exp       {
                                    $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                    printf("%s\n", $$.node->codigo_intermediario);
                                    printf("node filho1: %s\n", $$.node->node_filho1->codigo_intermediario);
                                    printf("node filho2: %s\n", $$.node->node_filho2->codigo_intermediario);   
                                    printf("exp -> exp <= exp\n");
                                } /* BINOP(MENOR_IGUAL, exp, exp) */
    | exp MAIOR_IGUAL exp       {
                                    $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                    printf("%s\n", $$.node->codigo_intermediario);
                                    printf("node filho1: %s\n", $$.node->node_filho1->codigo_intermediario);
                                    printf("node filho2: %s\n", $$.node->node_filho2->codigo_intermediario);   
                                    printf("exp -> exp >= exp\n"); 
                                } /* BINOP(MAIOR_IGUAL, exp, exp) */
    | exp AND exp               { 
                                    $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                    printf("%s\n", $$.node->codigo_intermediario);
                                    printf("node filho1: %s\n", $$.node->node_filho1->codigo_intermediario);
                                    printf("node filho2: %s\n", $$.node->node_filho2->codigo_intermediario);  
                                    printf("exp -> exp & exp\n");
                                } /* BINOP(AND, exp, exp) */
    | exp OR exp                {
                                    $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                    printf("%s\n", $$.node->codigo_intermediario);
                                    printf("node filho1: %s\n", $$.node->node_filho1->codigo_intermediario);
                                    printf("node filho2: %s\n", $$.node->node_filho2->codigo_intermediario);   
                                    printf("exp -> exp | exp\n");
                                } /* BINOP(OR, exp, exp) */

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

    | LET decs IN expseq END                            { 
                                                            $$.node = inicializa_node($2.node, $4.node, NULL, constroi_codigo_intermediario_eseq());
                                                            aponta_raiz_da_arvore($$.node);
                                                            printf("%s\n", $$.node->codigo_intermediario);
                                                            printf("node filho1: %s\n", $$.node->node_filho1->codigo_intermediario);
                                                            printf("node filho2: %s\n", $$.node->node_filho2->codigo_intermediario);
                                                            printf("exp -> let decs in expseq end\n"); 
                                                        } /* ESEQ(decs, expseq) ou SEQ(decs, expseq) */
    ;  

type_id: VARIAVEL                           {   
                                                $$.node = inicializa_node(NULL, NULL, NULL, "variavel");
                                                char* aux = (char*) malloc (strlen($1)+1);
                                                strcpy(aux, $1);
                                                $$.node->valor = aux;
                                                printf("type-id -> id\n"); 
                                            }
    ;

idexps: VIRGULA VARIAVEL IGUAL exp idexps   { printf("idexps  -> , id = exp idexps\n"); }
    |                                       { printf("idexps -> \n"); }
    ;

l_value: type_id PONTO VARIAVEL                 { printf("l-value -> type-id . id\n"); }
    | l_value PONTO VARIAVEL                    { printf("l-value -> l-value . id\n"); }
    | type_id ABRE_COLCHETE exp FECHA_COLCHETE  { printf("l-value -> type-id [ exp ]\n"); }
    | l_value ABRE_COLCHETE exp FECHA_COLCHETE  { printf("l-value -> l-value [ exp ]\n"); }
    ;

expseq: exp expseq1                             {    
                                                    printf("expseq -> exp expseq1\n"); 
                                                } /* Nenhum código intermediário neste nó */
    |                                           {   
                                                    $$.node = inicializa_node(NULL, NULL, NULL, "variavel");
                                                    printf("expseq -> \n"); 
                                                } /* Nenhum código intermediário neste nó */
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

tyfields: VARIAVEL DOIS_PONTOS type_id tyfields1    {   
                                                        // $$.node = inicializa_node(NULL, NULL, NULL, "VARIAVEL");
                                                        printf("tyfields -> id : type-id tyfields1\n"); 
                                                        
                                                        // struct simbolo *s = inicializa_simbolo($1, "int", "par", "0", "1");
                                                        // adiciona_simbolo(s);
                                                    }
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
    | VAR VARIAVEL DOIS_PONTOS type_id ATRIBUICAO exp   { 
                                                            $$.node = inicializa_node($4.node, $6.node, NULL, "variavel");
                                                            printf("%s OIEEEE\n", $2);
                                                            struct simbolo *s = inicializa_simbolo($2, ($4.node)->valor, "par", "1", "1");
                                                            adiciona_simbolo(s);
                                                            printf("vardec -> var id : type-id := exp\n");
                                                        }
    ;

fundec: FUNCTION VARIAVEL ABRE_PARENTESES tyfields FECHA_PARENTESES IGUAL exp   { printf("fundec -> function id ( tyfields ) = exp\n"); }
    | FUNCTION VARIAVEL ABRE_PARENTESES tyfields FECHA_PARENTESES DOIS_PONTOS type_id IGUAL exp { printf("fundec -> function id ( tyfields ) : type-id = exp\n"); }
    ;

decs: dec decs  { 
                    $$.node = inicializa_node($1.node, $2.node, NULL, "variavel");                                              
                    printf("decs -> dec decs\n"); 
                }
    |           { 
                    $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_vazio());
                    printf("%s\n", $$.node->codigo_intermediario);   
                    printf("decs -> \n"); 
                } /* Nenhum código intermediário neste nó */
    ;

dec: tydec      { printf("dec -> tydec\n"); }
    | vardec    { 
                    $$.node = inicializa_node($1.node, NULL, NULL, "variavel");
                    printf("dec -> vardec\n"); 
                }
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
    inicializa_tabela_simbolos();
    printf("\nREGRAS UTILIZADAS:\n\n");

    yyin = fopen(argv[1], "r" );
    
    if (!yyparse()){
        printf("\n----------------------------------------\n\n");
        printf("RESULTADO:\n\nANALISE SINTATICA OK!\n");
    }
    
    printCode(argv[1]);


    printf("\n----------------------------------------\n\n");
    printf("CODIGO INTERMEDIARIO GERADO:\n\n");
    codigo_intermediario_final = monta_codigo_intermediario_da_arvore(raiz_da_arvore);
    printf("%s\n", codigo_intermediario_final);

    printf("\n----------------------------------------\n\n");
    printf("TABELA DE SIMBOLOS:\n\n");
    
    imprime_tabela_simbolos();

    return 0;
}

void yyerror(const char* msg) {
    printf("\n----------------------------------------\n\n");
    printf("RESULTADO:\n\nERRO DE SINTAXE!\n");
}