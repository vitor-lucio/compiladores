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
    Funcoes utilitarias
////////////////////////////////////////////////////////////////////////////////
*/
    char* get_copia_string(char* string){
        char* copia_string = (char*) malloc (strlen(string)+1);
        strcpy(copia_string, string);
        return copia_string;
    }

    char* calcula(char* str1, char* str2, char* op){
        int x = atoi(str1), y = atoi(str2);
        int resultado = 0;
        char* string_resultado = (char*) malloc (strlen(str1) + strlen(str2) + 1);
        
        if(!strcmp(op, "+")){
            resultado = x + y;
        }else if(!strcmp(op, "*")){
            resultado = x * y;
        }else if(!strcmp(op, "-")){
            resultado = x - y;
        }else if(!strcmp(op, "*")){
            resultado = x / y;
        }
               
        sprintf(string_resultado, "%d", resultado);
        return string_resultado;
    }
    
/*
////////////////////////////////////////////////////////////////////////////////
    Constantes
////////////////////////////////////////////////////////////////////////////////
*/

/* 
    Parametros, a serem usados dentro do codigo intermediario,
    para indicar locais onde precisamos inserir outro codigo intermediario, dentro de uma string 
*/
char PARAMETRO1_CODIGO_INTERMEDIARIO[] = "$parametro1";
char PARAMETRO2_CODIGO_INTERMEDIARIO[] = "$parametro2";
char PARAMETRO3_CODIGO_INTERMEDIARIO[] = "$parametro3";

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
                                                        + 5 /* tamanho de: const() */
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "CONST ");
        strcat(codigo_intermediario, valor_constante);

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
        strcat(codigo_intermediario, "ESEQ(");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_temp(){
        char* codigo_intermediario = (char*) malloc(
                                                        // strlen(valor) 
                                                        + 5 /* tamanho de: temp */
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "TEMP t0");
        // strcat(codigo_intermediario, valor);

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_type_id(){
        char* codigo_intermediario = (char*) malloc(
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)                                 
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        // strcat(codigo_intermediario, valor);

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_move(){
        char* codigo_intermediario = (char*) malloc(      
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)                                              
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + 14 /* tamanho de: move(temp t2,) */
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "MOVE(");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_decs(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + 7                                                    
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "SEQ(");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ", ");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_cjump(){
        char* codigo_intermediario = (char*) malloc(    
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO3_CODIGO_INTERMEDIARIO)
                                                        + 11 /* tamanho de: cjump(,,,,) */                                                     
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "CJUMP(");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO); // PRECISO DESMEMBRAR ESSE PARAMETRO
        strcat(codigo_intermediario, ",");
        // strcat(codigo_intermediario, "");
        strcat(codigo_intermediario, ",");
        // strcat(codigo_intermediario, "");
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO); // TROCAR PRA LABEL
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO3_CODIGO_INTERMEDIARIO); // TROCAR PRA LABEL
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_tyfields1(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO)                                                     
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_tyfields(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO)                                                     
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_fundec1(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                       
                                                        strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + strlen(PARAMETRO3_CODIGO_INTERMEDIARIO)  
                                                        + 6                                                   
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "MOVE(");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ", ");
        strcat(codigo_intermediario, PARAMETRO3_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_fundec2(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO) 
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO)  
                                                        + 6                                                   
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "MOVE(");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ", ");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_dec(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)                                                                                                   
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_call1(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO) 
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO3_CODIGO_INTERMEDIARIO)
                                                        + 16                                                                                                
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "CALL(");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, "CONST 0");
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO3_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_call2(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO) 
                                                        + 6                                                                                                
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "CALL(");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_args(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)  
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + 1                                                                                                
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_args1(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)  
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + 1                                                                                                
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_ty(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)  
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + 1                                                                                                
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_tydec(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)                                                      
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        // strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_mem(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)  
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + strlen(PARAMETRO3_CODIGO_INTERMEDIARIO)
                                                        + 29                                                                                               
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "MEM(BINOP(PLUS,");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",BINOP(MUL,");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO3_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_l_value(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)                                                                                                           
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_expseq(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)                                                                                                           
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);

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
        
        novo_node->node_filho1 = node_filho1;
        novo_node->node_filho2 = node_filho2;
        novo_node->node_filho3 = node_filho3;
        /* Foi feita uma copia para evitar que o novo node aponte para a mesma memoria do parametro "codigo_intermediario" */
        novo_node->codigo_intermediario = get_copia_string(codigo_intermediario);

        printf("\n[    node pai: %s - %s ]\n", novo_node->codigo_intermediario, novo_node->tipo);
        if(novo_node->node_filho1) printf("[ node filho1: %s - %s ]\n", novo_node->node_filho1->codigo_intermediario, novo_node->node_filho1->tipo);
        if(novo_node->node_filho2) printf("[ node filho2: %s - %s ]\n", novo_node->node_filho2->codigo_intermediario, novo_node->node_filho2->tipo);
        if(novo_node->node_filho3) printf("[ node filho3: %s - %s ]\n", novo_node->node_filho3->codigo_intermediario, novo_node->node_filho3->tipo);

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

        if(sub_arvore->node_filho3){
            char* codigo_intermediario_do_node_filho = monta_codigo_intermediario_da_arvore(sub_arvore->node_filho3);

            substitui_parametro_por_codigo_intermediario_e_atribui_ao_node(sub_arvore, PARAMETRO3_CODIGO_INTERMEDIARIO, codigo_intermediario_do_node_filho);
            free(codigo_intermediario_do_node_filho);
        }
        
        /* Foi feita uma copia para evitar que outros ponteiros de char apontem para sub_arvore->codigo_intermediario,
           facilitando a interpretacao da memoria usada e permitindo o uso de free() para desalocar memoria nao usada
           e evitar erros inesperados */        
        return get_copia_string(sub_arvore->codigo_intermediario);
    }

/*
////////////////////////////////////////////////////////////////////////////////
    Estrutura da tabela de simbolos
////////////////////////////////////////////////////////////////////////////////
*/
    typedef struct simbolo{

        char* nome;
        char* tipo;
        char* classe;
        char* nivel;
        char* valor; 
        char* endereco;    

        struct simbolo *next;
        
    }simbolo;

    typedef struct tabela{
        struct simbolo *primeiro_elemento;
    }tabela;

    struct tabela tabela_simbolos;

/*
////////////////////////////////////////////////////////////////////////////////
    Funcoes da tabela de simbolo
////////////////////////////////////////////////////////////////////////////////
*/

    struct simbolo* inicializa_simbolo(char* nome, char* tipo, char* valor, char* classe, char* nivel, char* endereco){
        struct simbolo* novo_simbolo = (struct simbolo*) malloc (sizeof(struct simbolo));
        
        novo_simbolo->nome              = get_copia_string(nome);
        novo_simbolo->tipo              = get_copia_string(tipo);
        novo_simbolo->classe            = get_copia_string(classe);
        novo_simbolo->nivel = get_copia_string(nivel);
        novo_simbolo->endereco          = get_copia_string(endereco);
        novo_simbolo->valor             = get_copia_string(valor);

        return novo_simbolo;
    }

    void inicializa_tabela_simbolos(){
        tabela_simbolos.primeiro_elemento = NULL;
    }

    struct simbolo* busca_simbolo(struct simbolo *s){
        struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
        
        while(iterador != NULL){
            if(!strcmp(iterador->nome, s->nome)){
                return iterador;
            }
            iterador = iterador->next;
        }

        return NULL;
    }

    struct simbolo* busca_simbolo_pelo_nome(char* nome){
        struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
        
        while(iterador != NULL){
            if(!strcmp(iterador->nome, nome)){
                return iterador;
            }
            iterador = iterador->next;
        }

        return NULL;
    }


    void adiciona_simbolo(struct simbolo *s){
        if(!tabela_simbolos.primeiro_elemento){
            tabela_simbolos.primeiro_elemento = s;
            tabela_simbolos.primeiro_elemento->next = NULL;

            printf("\nSIMBOLO ADICIONADO: %s %s\n", tabela_simbolos.primeiro_elemento->nome, tabela_simbolos.primeiro_elemento->tipo);
        }else{

            if(busca_simbolo(s)){
                printf("\nSIMBOLO %s JA EXISTE!\n", s->nome);
                return;
            }

            struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
            
            while(iterador->next != NULL){
                iterador = iterador->next;
            }
            
            iterador->next = s;
            iterador->next->next = NULL;

            printf("\nSIMBOLO ADICIONADO: %s %s\n", iterador->next->nome, iterador->next->tipo);
        }
    }

    void atualiza_simbolo(struct simbolo *s, char* tipo){
        s->tipo = tipo;
    }

    void imprime_tabela_simbolos(){
        struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
        
        printf("|    NOME   |    TIPO   |   VALOR   |   CLASSE  |   NIVEL   |  ENDERECO |");
        printf("\nx-----------x-----------x-----------x-----------x-----------x-----------x");

        while(iterador != NULL){
            printf("\n|%10s |%10s |%10s |%10s |%10s |%10s |", iterador->nome, iterador->tipo, 
                                                iterador->valor, iterador->classe, 
                                                iterador->nivel, iterador->endereco);
            iterador = iterador->next;
        }

        printf("\n");
    }

/*
////////////////////////////////////////////////////////////////////////////////
    Funcoes de tratamento de erros
////////////////////////////////////////////////////////////////////////////////
*/

    char* verifica_e_define_tipos_binop(char* tipo_parametro_1, char* tipo_parametro_2){
        if(strcmp(tipo_parametro_1, tipo_parametro_2)){
            printf("ERRO DE TIPAGEM!\n");
            exit(1);
        }

        return tipo_parametro_1; 
    }

    char* verifica_e_define_tipos_vardec(char* tipo_parametro_1, char* tipo_parametro_2){
        if(strcmp(tipo_parametro_1, tipo_parametro_2)){
            printf("ERRO DE TIPAGEM!\n");
            exit(1);
        }

        return tipo_parametro_2;
    }                                                                                                                                                   
                                                                                                            
%}

%union { 
	struct node_da_arvore {
		struct node* node;
    } node_da_arvore;

    char* valor_constante;
} 

%token <valor_constante> NUMERO STRING_CONSTANTE NIL BREAK LET IN END FUNCTION TYPE VAR ARRAY DOIS_PONTOS VIRGULA PONTO_E_VIRGULA PONTO ABRE_CHAVES FECHA_CHAVES ABRE_COLCHETE FECHA_COLCHETE ABRE_PARENTESES FECHA_PARENTESES
%nonassoc <valor_constante> WHILE IF FOR TO ATRIBUICAO VARIAVEL
%nonassoc <valor_constante> THEN
%nonassoc <valor_constante> ELSE DO OF
%left <valor_constante> OR
%left <valor_constante> AND
%left <valor_constante> MAIOR_QUE MENOR_QUE IGUAL DIFERENTE MAIOR_IGUAL MENOR_IGUAL
%left <valor_constante> MAIS MENOS
%left <valor_constante> MULTIPLICACAO DIVISAO

%type <node_da_arvore> exp type_id idexps l_value expseq expseq1 args args1 tyfields tyfields1 ty tydec vardec fundec decs dec

%start exp

%%
/* EXPRESSOES */
exp:  
      exp MAIS exp                                                  {                                                            
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                                                        $$.node->tipo = verifica_e_define_tipos_binop(($1.node)->tipo, ($3.node)->tipo);                                                                        
                                                                        printf("exp -> exp + exp\n"); 
                                                                    } /* BINOP(MAIS, exp, exp) */
    | exp MENOS exp                                                 {
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                                                        $$.node->tipo = verifica_e_define_tipos_binop(($1.node)->tipo, ($3.node)->tipo);                                                                        
                                                                        printf("exp -> exp - exp\n"); 
                                                                    } /* BINOP(MENOS, exp, exp) */
    | exp MULTIPLICACAO exp                                         {
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                                                        $$.node->tipo = verifica_e_define_tipos_binop(($1.node)->tipo, ($3.node)->tipo);                                                                        
                                                                        printf("exp -> exp * exp\n"); 
                                                                    } /* BINOP(MULTIPLICACAO, exp, exp) */
    | exp DIVISAO exp                                               {
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                                                        $$.node->tipo = verifica_e_define_tipos_binop(($1.node)->tipo, ($3.node)->tipo);                                                                        
                                                                        printf("exp -> exp / exp\n"); 
                                                                    } /* BINOP(DIVISAO, exp, exp) */

    | MENOS exp                                                     { 
                                                                        $$.node = inicializa_node($2.node, NULL, NULL, "TODO");
                                                                        printf("exp -> - exp\n"); 
                                                                    } /* CONST(- exp) */

    | NUMERO                                                        {
                                                                        $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_const($1));
                                                                        $$.node->tipo = "int";
                                                                        // $$.node->valor = $1;
                                                                        printf("exp -> num\n");
                                                                    } /* CONST(NUMERO) */
    | STRING_CONSTANTE                                              { 
                                                                        $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_const($1));
                                                                        $$.node->tipo = "string";
                                                                        printf("exp -> string\n"); 
                                                                    } /* 'STRING_CONSTANTE' */
    | NIL                                                           { 
                                                                        $$.node = inicializa_node(NULL, NULL, NULL, "TODO");
                                                                        printf("exp -> nil\n"); 
                                                                    } /* NIL */
    | exp IGUAL exp                                                 {
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                                                        printf("exp -> exp = exp\n"); 
                                                                    } /* BINOP(IGUAL, exp, exp) */
    | exp DIFERENTE exp                                             {
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                                                        printf("exp -> exp <> exp\n"); 
                                                                    } /* BINOP(DIFERENTE, exp, exp) */   
    | exp MENOR_QUE exp                                             {
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));  
                                                                        printf("exp -> exp < exp\n"); 
                                                                    } /* BINOP(MENOR_QUE, exp, exp) */
    | exp MAIOR_QUE exp                                             {
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));  
                                                                        printf("exp -> exp > exp\n"); 
                                                                    } /* BINOP(MAIOR_QUE, exp, exp) */
    | exp MENOR_IGUAL exp                                           {
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));  
                                                                        printf("exp -> exp <= exp\n");
                                                                    } /* BINOP(MENOR_IGUAL, exp, exp) */
    | exp MAIOR_IGUAL exp                                           {
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));  
                                                                        printf("exp -> exp >= exp\n"); 
                                                                    } /* BINOP(MAIOR_IGUAL, exp, exp) */
    | exp AND exp                                                   { 
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2)); 
                                                                        printf("exp -> exp & exp\n");
                                                                    } /* BINOP(AND, exp, exp) */
    | exp OR exp                                                    {
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));  
                                                                        printf("exp -> exp | exp\n");
                                                                    } /* BINOP(OR, exp, exp) */

    | IF exp THEN exp ELSE exp                                      { 
                                                                        $$.node = inicializa_node($2.node, $4.node, $6.node, constroi_codigo_intermediario_cjump());
                                                                        printf("exp -> if exp then exp else exp\n"); 
                                                                    } /* CJUMP(exp1.op, exp1.exp1, exp1.exp2, Labelexp2, Labelexp3) */
    | IF exp THEN exp                                               { 
                                                                        $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_cjump());
                                                                        printf("exp -> if exp then exp\n"); 
                                                                    } /* CJUMP(exp1.op, exp1.exp1, exp1.exp2, Labelexp2, enderecoDoCodigoAposIf) */
    | WHILE exp DO exp                                              { 
                                                                        $$.node = inicializa_node($2.node, $4.node, NULL, "TODO");
                                                                        printf("exp -> while exp do exp\n"); 
                                                                    } /* CJUMP(exp1.op, exp1.exp1, exp1.exp2, Labelexp2, enderecoDoCodigoAposWhile) */
    | FOR VARIAVEL ATRIBUICAO exp TO exp DO exp                     { 
                                                                        $$.node = inicializa_node($4.node, $6.node, $8.node, "TODO");
                                                                        printf("exp -> for id := exp to exp do exp\n"); 
                                                                    } /* CJUMP(MENOR_IGUAL, exp1.exp1, exp1.exp2, Labelexp2, enderecoDoCodigoAposWhile) */
    | BREAK                                                         {  
                                                                        printf("exp -> break\n"); 
                                                                    } /* JUMP(labelAnteriorAoDoLabelQueExecutouBreak + proximoComandoDoLabelQueExecutouBreak, labelAnteriorAoDoLabelQueExecutouBreak + proximoComandoDoLabelQueExecutouBreak) */
    | type_id ABRE_CHAVES VARIAVEL IGUAL exp idexps FECHA_CHAVES    { 
                                                                        $$.node = inicializa_node($1.node, $5.node, $6.node, "TODO");
                                                                        printf("exp -> type-id { id = exp idexps }\n"); 
                                                                    }
    | type_id ABRE_COLCHETE exp FECHA_COLCHETE OF exp               { 
                                                                        $$.node = inicializa_node($1.node, $3.node, $6.node, constroi_codigo_intermediario_call1());
                                                                        $$.node->tipo  = ($1.node)->tipo;
                                                                        $$.node->valor = ($3.node)->valor;
                                                                        printf("exp -> type-id [ exp ] of exp\n"); 
                                                                    }
    | l_value ATRIBUICAO exp                                        { 
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, "TODO");
                                                                        printf("exp -> l-value := exp\n"); 
                                                                    }
    | type_id ATRIBUICAO exp                                        { 
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_move());
                                                                        printf("exp -> type-id := exp\n"); 
                                                                    }
    | type_id                                                       { 
                                                                        $$.node = inicializa_node($1.node, NULL, NULL, constroi_codigo_intermediario_type_id()); 
                                                                        $$.node->tipo = ($1.node)->tipo; 
                                                                        printf("exp -> type-id\n"); 
                                                                    }
    | l_value                                                       { 
                                                                        $$.node = inicializa_node($1.node, NULL, NULL, constroi_codigo_intermediario_l_value());
                                                                        printf("exp -> l-value\n"); 
                                                                    }
    | ABRE_PARENTESES expseq FECHA_PARENTESES                       { 
                                                                        $$.node = inicializa_node($2.node, NULL, NULL, "TODO");
                                                                        printf("exp -> ( expseq )\n"); 
                                                                    } /* Nenhum código intermediário neste nó */
    | VARIAVEL ABRE_PARENTESES args FECHA_PARENTESES                { 
                                                                        $$.node = inicializa_node($3.node, NULL, NULL, constroi_codigo_intermediario_call2());
                                                                        printf("exp -> id ( args )\n"); 
                                                                    }
    | LET decs IN expseq END                                        { 
                                                                        $$.node = inicializa_node($2.node, $4.node, NULL, constroi_codigo_intermediario_eseq());
                                                                        aponta_raiz_da_arvore($$.node);
                                                                        printf("exp -> let decs in expseq end\n"); 
                                                                    } /* ESEQ(decs, expseq) ou SEQ(decs, expseq) */
    ;  

/* NOME DE TIPO ou VARIAVEL */
type_id: 
      VARIAVEL  {   
                    $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_temp());                                                        
                    $$.node->valor = get_copia_string($1); 

                    struct simbolo* simbolo_encontrado = busca_simbolo_pelo_nome($1);
                    if(simbolo_encontrado){
                        $$.node->tipo = simbolo_encontrado->tipo;                                                                                                                              
                    }else{
                        $$.node->tipo = get_copia_string($1);  
                    }
                                                                                                    

                    // if(!(!strcmp($1,"int") || !strcmp($1,"string")))
                    // {
                        // struct simbolo* novo_simbolo = inicializa_simbolo($1, "?", "?", "?", "?", "?");
                        // struct simbolo* simbolo_encontrado = busca_simbolo(novo_simbolo);

                        // if(simbolo_encontrado){
                            // if(!strcmp(simbolo_encontrado->classe,"var")){
                                // $$.node->tipo = simbolo_encontrado->tipo;
                            // }
                        // }else{ // TODO: tirar isso e colocar aonde o type_id eh chamado (olhar declaracao de registros recursivos e todos os pontos que chamam essa regra)
                            // printf("ERRO: VARIAVEL NAO DECLARADA!\n");
                            // exit(1);
                        // }
                    // }

                    printf("type-id -> id\n"); 
                }
    ;

/**/
idexps: 
      VIRGULA VARIAVEL IGUAL exp idexps     { 
                                                $$.node = inicializa_node($4.node, $5.node, NULL, "TODO");
                                                printf("idexps  -> , id = exp idexps\n"); 
                                            }
    |                                       { 
                                                $$.node = inicializa_node(NULL, NULL, NULL, "TODO");
                                                printf("idexps -> \n"); 
                                            }
    ;

/**/
l_value: 
      type_id PONTO VARIAVEL                            { 
                                                            $$.node = inicializa_node($1.node, NULL, NULL, "TODO");
                                                            printf("l-value -> type-id . id\n"); 
                                                        }
    | l_value PONTO VARIAVEL                            { 
                                                            $$.node = inicializa_node($1.node, NULL, NULL, "TODO");
                                                            printf("l-value -> l-value . id\n"); 
                                                        }
    | type_id ABRE_COLCHETE exp FECHA_COLCHETE          { 
                                                            $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_mem());
                                                            printf("l-value -> type-id [ exp ]\n"); 
                                                        }
    | l_value ABRE_COLCHETE exp FECHA_COLCHETE          { 
                                                            $$.node = inicializa_node($1.node, $3.node, NULL, "TODO");
                                                            printf("l-value -> l-value [ exp ]\n"); 
                                                        }
    ;

/**/
expseq: 
      exp expseq1           {    
                                $$.node = inicializa_node($1.node, $2.node, NULL, constroi_codigo_intermediario_expseq());
                                printf("expseq -> exp expseq1\n"); 
                            } /* Nenhum código intermediário neste nó */
    |                       {   
                                $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_vazio());
                                printf("expseq -> \n"); 
                            } /* Nenhum código intermediário neste nó */
    ;

/**/
expseq1: 
      PONTO_E_VIRGULA exp expseq1               { 
                                                    $$.node = inicializa_node($2.node, $3.node, NULL, "TODO");
                                                    printf("expseq1 -> ; exp expseq1\n"); 
                                                } /* Nenhum código intermediário neste nó */
    |                                           { 
                                                    $$.node = inicializa_node(NULL, NULL, NULL, "TODO");
                                                    printf("expseq1 -> \n"); 
                                                } /* Nenhum código intermediário neste nó */
    ;

/**/
args: 
      exp args1                 { 
                                    $$.node = inicializa_node($1.node, $2.node, NULL, constroi_codigo_intermediario_args());                                                            
                                    printf("args -> exp args1\n"); 
                                }
    |                           { 
                                    $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_vazio());
                                    printf("args -> \n"); 
                                }
    ;

/**/
args1: 
      VIRGULA exp args1             { 
                                        $$.node = inicializa_node($2.node, $3.node, NULL, constroi_codigo_intermediario_args1());
                                        printf("args1 -> , exp args1\n"); 
                                    }
    |                               { 
                                        $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_vazio());
                                        printf("args1 -> \n"); 
                                    }
    ;

/**/
tyfields: 
      VARIAVEL DOIS_PONTOS type_id tyfields1            {   
                                                            $$.node = inicializa_node($3.node, $4.node, NULL, constroi_codigo_intermediario_tyfields());
                                                            
                                                            struct simbolo *simbolo_encontrado = busca_simbolo_pelo_nome($1);
                                                            atualiza_simbolo(simbolo_encontrado, ($3.node)->valor);                                                                                                                                
                                                            
                                                            printf("tyfields -> id : type-id tyfields1\n"); 
                                                        }
    |                                                   { 
                                                            $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_vazio());
                                                            printf("tyfields -> \n"); 
                                                        }
    ;   

/**/
tyfields1: 
      VIRGULA VARIAVEL DOIS_PONTOS type_id tyfields1        { 
                                                                $$.node = inicializa_node($4.node, $5.node, NULL, constroi_codigo_intermediario_tyfields1());
                                                                
                                                                struct simbolo *simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                                atualiza_simbolo(simbolo_encontrado, ($4.node)->valor);                                                                                                                                
                                                                
                                                                printf("tyfields1 -> , id : type-id tyfields1\n"); 
                                                            }
    |                                                       { 
                                                                $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_vazio());
                                                                printf("tyfields1 -> \n"); 
                                                            }
    ;

/**/
ty: 
      VARIAVEL                                                          {  
                                                                            $$.node = inicializa_node(NULL, NULL, NULL, ""); 
                                                                            $$.node->tipo = $1;                                                                           
                                                                            printf("ty -> id\n"); 
                                                                        }
    | ABRE_CHAVES VARIAVEL DOIS_PONTOS type_id tyfields1 FECHA_CHAVES   {   
                                                                            $$.node = inicializa_node($4.node, $5.node, NULL, "");                                                        

                                                                            struct simbolo *simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                                            atualiza_simbolo(simbolo_encontrado, ($4.node)->valor);                                                                                                                                
                                                                                                                                            
                                                                            printf("ty -> { id : type-id tyfields1 }\n"); 
                                                                        }
    | ARRAY OF VARIAVEL                                                 { 
                                                                            $$.node = inicializa_node(NULL, NULL, NULL, "");                                                        
                                                                            $$.node->tipo = "array of";
                                                                            printf("ty -> array of id\n"); 
                                                                        }
    ;

/**/
tydec: 
      TYPE VARIAVEL IGUAL ty                            { 
                                                            $$.node = inicializa_node($4.node, NULL, NULL, constroi_codigo_intermediario_tydec());

                                                            struct simbolo *simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                            atualiza_simbolo(simbolo_encontrado, ($4.node)->tipo);                                                                                                                                   

                                                            printf("tydec -> type id = ty\n"); 
                                                        }
    ;

/**/
vardec: 
      VAR VARIAVEL ATRIBUICAO exp                       { 
                                                            $$.node  = inicializa_node($4.node, NULL, NULL, constroi_codigo_intermediario_move());
                                                            
                                                            struct simbolo *simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                            atualiza_simbolo(simbolo_encontrado, ($4.node)->tipo);                                                                                                                                                                                            

                                                            printf("vardec -> var id := exp\n"); 
                                                        }
    | VAR VARIAVEL DOIS_PONTOS type_id ATRIBUICAO exp   {  
                                                            $$.node = inicializa_node($4.node, $6.node, NULL, constroi_codigo_intermediario_move());
                                                            
                                                            struct simbolo *simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                            atualiza_simbolo(simbolo_encontrado, verifica_e_define_tipos_vardec(($4.node)->valor, ($6.node)->tipo));                                                                                                                                
                                                                
                                                            printf("vardec -> var id : type-id := exp\n");
                                                        }
    ;

/**/
fundec: 
      FUNCTION VARIAVEL ABRE_PARENTESES tyfields FECHA_PARENTESES IGUAL exp                     { 
                                                                                                    $$.node = inicializa_node($4.node, $7.node, NULL, constroi_codigo_intermediario_fundec2());
                                                                                                    
                                                                                                    struct simbolo *simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                                                                    atualiza_simbolo(simbolo_encontrado, "void");                                                                                                                              
                                                                                                    
                                                                                                    printf("fundec -> function id ( tyfields ) = exp\n"); 
                                                                                                }
    | FUNCTION VARIAVEL ABRE_PARENTESES tyfields FECHA_PARENTESES DOIS_PONTOS type_id IGUAL exp {                                                                                                     
                                                                                                    $$.node = inicializa_node($4.node, $7.node, $9.node, constroi_codigo_intermediario_fundec1());                                                                                                  
                                                                                                    
                                                                                                    struct simbolo *simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                                                                    atualiza_simbolo(simbolo_encontrado, verifica_e_define_tipos_vardec(($7.node)->valor, ($9.node)->tipo));                                                                                                                              
                                                                                                    
                                                                                                    printf("fundec -> function id ( tyfields ) : type-id = exp\n"); 
                                                                                                }
    ;

/**/
decs: 
      dec decs          { 
                            $$.node = inicializa_node($1.node, $2.node, NULL, constroi_codigo_intermediario_decs()); 
                            printf("decs -> dec decs\n"); 
                        }
    |                   { 
                            $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_vazio());
                            printf("decs -> \n"); 
                        } /* Nenhum código intermediário neste nó */
    ;

/**/
dec: 
      tydec         { 
                        $$.node = inicializa_node($1.node, NULL, NULL, "");
                        printf("dec -> tydec\n"); 
                    }
    | vardec        { 
                        $$.node = inicializa_node($1.node, NULL, NULL, "");                                                           
                        printf("dec -> vardec\n"); 
                    }
    | fundec        { 
                        $$.node = inicializa_node($1.node, NULL, NULL, "");                                                           
                        printf("dec -> fundec\n"); 
                    }
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

    
    // printCode(argv[1]);

    printf("\n----------------------------------------\n\n");
    imprime_tabela_simbolos();
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