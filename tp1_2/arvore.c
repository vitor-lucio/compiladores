#include "erros.c"

/*
////////////////////////////////////////////////////////////////////////////////
    Estrutura do codigo intermediario final
////////////////////////////////////////////////////////////////////////////////
*/

char* codigo_intermediario_final;
char* codigo_abstrato_final;
char* codigo_intermediario_funcao = "\0";

/*
////////////////////////////////////////////////////////////////////////////////
    Estrutura da arvore
////////////////////////////////////////////////////////////////////////////////
*/
    struct node {
        char* codigo_funcao;
		char* codigo_intermediario;
        char* codigo_abstrato;
        struct node* node_filho1;
        struct node* node_filho2;
        struct node* node_filho3;
        char* tipo;
        char* valor;
        char* classe;
        char* nome;
        int num_arrays;
        int numero_de_parametros;
        int dec;
	};

    struct node* raiz_da_arvore; /* raiz da arvore */
    struct node* raiz_da_arvore_funcoes; /* raiz da arvore */

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

    struct node* inicializa_node(char* codigo_abstrato, struct node* node_filho1, struct node *node_filho2, struct node *node_filho3, char* codigo_intermediario) {
        struct node* novo_node = (struct node*) malloc(sizeof(struct node));
        
        novo_node->node_filho1 = node_filho1;
        novo_node->node_filho2 = node_filho2;
        novo_node->node_filho3 = node_filho3;
        /* Foi feita uma copia para evitar que o novo node aponte para a mesma memoria do parametro "codigo_intermediario" */
        novo_node->codigo_intermediario = get_copia_string(codigo_intermediario);
        novo_node->codigo_abstrato = get_copia_string(codigo_abstrato);
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

    void substitui_parametro_por_codigo_abstrato_e_atribui_ao_node(struct node* node, char* nome_do_parametro, char* codigo_abstrato){
        char* codigo_abstrato_da_sub_arvore_com_parametro = replaceWord(
                                                                                node->codigo_abstrato, 
                                                                                nome_do_parametro,
                                                                                codigo_abstrato
                                                                            );

        free(node->codigo_abstrato);
        node->codigo_abstrato = codigo_abstrato_da_sub_arvore_com_parametro;
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

    
    char* monta_codigo_abstrato_da_arvore(struct node* sub_arvore){
        if(sub_arvore->node_filho1){
            char* codigo_abstrato_do_node_filho = monta_codigo_abstrato_da_arvore(sub_arvore->node_filho1);

            substitui_parametro_por_codigo_abstrato_e_atribui_ao_node(sub_arvore, PARAMETRO1_CODIGO_ABSTRATO, codigo_abstrato_do_node_filho);
            free(codigo_abstrato_do_node_filho);
        }
       
        if(sub_arvore->node_filho2){
            char* codigo_abstrato_do_node_filho = monta_codigo_abstrato_da_arvore(sub_arvore->node_filho2);
       
            substitui_parametro_por_codigo_abstrato_e_atribui_ao_node(sub_arvore, PARAMETRO2_CODIGO_ABSTRATO, codigo_abstrato_do_node_filho); 
            free(codigo_abstrato_do_node_filho);
        }

        if(sub_arvore->node_filho3){
            char* codigo_abstrato_do_node_filho = monta_codigo_abstrato_da_arvore(sub_arvore->node_filho3);

            substitui_parametro_por_codigo_abstrato_e_atribui_ao_node(sub_arvore, PARAMETRO3_CODIGO_ABSTRATO, codigo_abstrato_do_node_filho);
            free(codigo_abstrato_do_node_filho);
        }

        /* Foi feita uma copia para evitar que outros ponteiros de char apontem para sub_arvore->codigo_abstrato,
           facilitando a interpretacao da memoria usada e permitindo o uso de free() para desalocar memoria nao usada
           e evitar erros inesperados */        
        return get_copia_string(sub_arvore->codigo_abstrato);
    }


    int procura_parametros_da_funcao_na_arvore(simbolo* func, struct node* sub_arvore){
        int aux = 0;
        
        if(sub_arvore->node_filho1){
            aux = procura_parametros_da_funcao_na_arvore(func, sub_arvore->node_filho1);
            // printf("\n");
            if(sub_arvore->node_filho1->valor != NULL) {
                if(procura_simb_nas_n_posicoes_a_frente(func, sub_arvore->node_filho1->valor)){
                    // printf("$$$ ACHEI NOS PARAMETROS DA FUNCAO %s O SIMBOLO %s $$$\n", func->nome, sub_arvore->node_filho1->valor);
                }else if(procura_simb_nos_simbolos_globais(sub_arvore->node_filho1->valor)){
                    // printf("$$$ ACHEI %s DA FUNCAO %s NOS SIMBOLOS GLOBAIS $$$\n", sub_arvore->node_filho1->valor, func->nome);
                }else return 0;
                aux = 1;
            }
        }

        if(sub_arvore->node_filho2){
            aux = procura_parametros_da_funcao_na_arvore(func, sub_arvore->node_filho2);
            // printf("\n");
            if(sub_arvore->node_filho2->valor != NULL) {
                if(procura_simb_nas_n_posicoes_a_frente(func, sub_arvore->node_filho2->valor)){
                    // printf("$$$ ACHEI NOS PARAMETROS DA FUNCAO %s O SIMBOLO %s $$$\n", func->nome, sub_arvore->node_filho2->valor);
                }else if(procura_simb_nos_simbolos_globais(sub_arvore->node_filho2->valor)){
                    // printf("$$$ ACHEI %s DA FUNCAO %s NOS SIMBOLOS GLOBAIS $$$\n", sub_arvore->node_filho2->valor, func->nome);
                }else return 0;
                aux = 1;
            }
        }

        if(sub_arvore->node_filho3){
            aux = procura_parametros_da_funcao_na_arvore(func, sub_arvore->node_filho3);
            // printf("\n");
            if(sub_arvore->node_filho3->valor != NULL) {
                if(procura_simb_nas_n_posicoes_a_frente(func, sub_arvore->node_filho3->valor)){
                    // TODO: mandar o tipo do node_filho pra comparar com o tipo do simbolo da tabela encontrado (se for diferente: erro)
                    // printf("$$$ ACHEI NOS PARAMETROS DA FUNCAO %s O SIMBOLO %s $$$\n", func->nome, sub_arvore->node_filho3->valor);
                }else if(procura_simb_nos_simbolos_globais(sub_arvore->node_filho3->valor)){
                    // TODO: mandar o tipo do node_filho pra comparar com o tipo do simbolo da tabela encontrado (se for diferente: erro)
                    // printf("$$$ ACHEI %s DA FUNCAO %s NOS SIMBOLOS GLOBAIS $$$\n", sub_arvore->node_filho3->valor, func->nome);
                }else return 0;
                aux = 1;
            }
        }

        return aux;
    }
/*
////////////////////////////////////////////////////////////////////////////////
    Funcoes de construcao das strings de codigo intermediario
////////////////////////////////////////////////////////////////////////////////
*/

    char* constroi_codigo_intermediario_vazio(){

        char* codigo_intermediario = (char*) malloc(
                                                        1 /* \0 da string, indicando seu fim em C */
                                                        + 12
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "EXP(CONST 0)");

        return codigo_intermediario;
    }

    char* constroi_codigo_abstrato_vazio(){

        char* codigo_intermediario = (char*) malloc(
                                                        1 /* \0 da string, indicando seu fim em C */
                                                        +strlen("\nSeqExp()")
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "\n SeqExp()\n");

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

    char* constroi_codigo_abstrato_const(char* valor_constante){

        char* codigo_intermediario = (char*) malloc(
                                                        strlen(valor_constante) 
                                                        + strlen("IntExp()")
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "IntExp(");
        strcat(codigo_intermediario, valor_constante);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_abstrato_constStr(char* valor_constante){

        char* codigo_intermediario = (char*) malloc(
                                                        strlen(valor_constante) 
                                                        + strlen("StringExp()")
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "StringExp(");
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
        strcat(codigo_intermediario, "BINOP(");
        strcat(codigo_intermediario, tipo_operacao);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_abstrato_binop(char* tipo_operacao){

        char* codigo_intermediario = (char*) malloc(
                                                        strlen(tipo_operacao) 
                                                        + strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + 9 /* tamanho de: binop(,,) */ 
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "OpExp(");
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

    char* constroi_codigo_abstrato_eseq(){

        char* codigo_intermediario = (char*) malloc(
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + 7 /* tamanho de: eseq(,) */ 
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "LetExp(\n ");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_temp(int temp){
        char* codigo_intermediario = (char*) malloc(
                                                        // strlen(valor) 
                                                        + 5 /* tamanho de: temp */
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        char t[10];
        sprintf(t,"%d",temp);
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "TEMP t");
        strcat(codigo_intermediario, t);
        // strcat(codigo_intermediario, valor);

        return codigo_intermediario;
    }

    char* constroi_codigo_abstrato_temp(char* valor){
        char* codigo_intermediario = (char*) malloc(
                                                        // strlen(valor) 
                                                        + strlen(valor)
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
      
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, valor);
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

    char* constroi_codigo_abstrato_type_id(){
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

    char* constroi_codigo_intermediario_vardec2(int temp){
        char* codigo_intermediario = (char*) malloc(      
                                                        strlen("TEMP t0")                                              
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + 14 /* tamanho de: move(temp t2,) */
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        char t[10];
        sprintf(t,"%d",temp);
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "MOVE(");
        strcat(codigo_intermediario, "TEMP t");
        strcat(codigo_intermediario, t);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_abstrato_vardec2(char* nome){
        char* codigo_intermediario = (char*) malloc(      
                                                        strlen(nome)                                              
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + strlen(PARAMETRO1_CODIGO_INTERMEDIARIO) 
                                                        + 9 /* tamanho de: move(temp t2,) */
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "VarDec(");
        strcat(codigo_intermediario, nome);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_vardec1(int temp){
        char* codigo_intermediario = (char*) malloc(      
                                                        strlen("TEMP t0")                                              
                                                        + strlen(PARAMETRO1_CODIGO_INTERMEDIARIO) 
                                                        + 14 /* tamanho de: move(temp t2,) */
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        char t[10];
        sprintf(t,"%d",temp);
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "MOVE(");
        strcat(codigo_intermediario, "TEMP t");
        strcat(codigo_intermediario, t);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_abstrato_vardec1(char* nome){
        char* codigo_intermediario = (char*) malloc(      
                                                        strlen(nome)                                              
                                                        + strlen(PARAMETRO1_CODIGO_INTERMEDIARIO) 
                                                        + 9 /* tamanho de: move(temp t2,) */
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "VarDec(");
        strcat(codigo_intermediario, nome);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_decs1(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + 7                                                    
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "SEQ(");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_abstrato_decs(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + 10 
                                                        +strlen("\n ")                                                   
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "DecList(\n  ");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",\n  ");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_decs1_vazio(){
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

    char* constroi_codigo_abstrato_decs1_vazio(){
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

    char* constroi_codigo_intermediario_decs2(){

        char* codigo_intermediario = (char*) malloc(
                                                        1 /* \0 da string, indicando seu fim em C */
                                                        + 12
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "EXP(CONST 0)");

        return codigo_intermediario;
    }

    char* constroi_codigo_abstrato_decs2(){

        char* codigo_intermediario = (char*) malloc(
                                                        1 /* \0 da string, indicando seu fim em C */
                                                        + 12
                                                        +strlen("\n ")
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "DecList()");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_exp(){

        char* codigo_intermediario = (char*) malloc(       
                                                        + 5 /* tamanho de exp() */                                                
                                                        + 7 /* tamanho de: const 0 */
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "EXP(");
        strcat(codigo_intermediario, "CONST ");
        strcat(codigo_intermediario, "0");
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

    char* constroi_codigo_intermediario_tyfields11(){
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

    char* constroi_codigo_abstrato_tyfields11(char* nome){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO)
                                                        + strlen("FieldList(,,)")        
                                                        + strlen(nome)                                             
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "Fieldlist(");
        strcat(codigo_intermediario, nome);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_tyfields12(){

        char* codigo_intermediario = (char*) malloc(
                                                        1 /* \0 da string, indicando seu fim em C */
                                                        + 12
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "EXP(CONST 0)");

        return codigo_intermediario;
    }

    char* constroi_codigo_abstrato_tyfields12(){

        char* codigo_intermediario = (char*) malloc(
                                                        1 /* \0 da string, indicando seu fim em C */
                                                        + strlen("FieldList()")
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "FieldList()");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_tyfields2(){

        char* codigo_intermediario = (char*) malloc(
                                                        1 /* \0 da string, indicando seu fim em C */
                                                        + 12
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "EXP(CONST 0)");

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

    char* constroi_codigo_abstrato_tyfields(char* nome){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO)
                                                        + strlen("FieldList(,,)")        
                                                        + strlen(nome)                                             
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "Fieldlist(");
        strcat(codigo_intermediario, nome);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

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
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO3_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_abstrato_fundec1(char* nome){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO) 
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO)
                                                        +strlen(PARAMETRO3_CODIGO_INTERMEDIARIO) 
                                                        + strlen(nome) 
                                                        + 6                                                   
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, nome);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ", ");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ", ");
        strcat(codigo_intermediario, PARAMETRO3_CODIGO_INTERMEDIARIO);
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

    char* constroi_codigo_abstrato_fundec2(char* nome){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO) 
                                                        +strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        + strlen("void") 
                                                        + strlen(nome) 
                                                        + 6                                                   
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, nome);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ", ");
        strcat(codigo_intermediario, "void");
        strcat(codigo_intermediario, ",");
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
                                                        strlen("NAME initarray") 
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO3_CODIGO_INTERMEDIARIO)
                                                        + 16                                                                                                
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "CALL(");
        strcat(codigo_intermediario, "NAME initarray");
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, "CONST 0");
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO3_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_call3(int temp){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen("NAME initarray") 
                                                        + strlen("TEMP t0")
                                                        + strlen(PARAMETRO3_CODIGO_INTERMEDIARIO)
                                                        + 16                                                                                                
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        char t[10];
        sprintf(t,"%d",temp);
        codigo_intermediario[0] = '\0';        
        strcat(codigo_intermediario, "CALL(");
        strcat(codigo_intermediario, "NAME initarray");
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, "CONST 0");
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, "TEMP t");
        strcat(codigo_intermediario, t);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO3_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_abstrato_call3(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen("ArrayExp(,,)") 
                                                        + strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO)
                                                        + strlen(PARAMETRO3_CODIGO_INTERMEDIARIO)                                                                                                                                                       
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';        
        strcat(codigo_intermediario, "ArrayExp(");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
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

    char* constroi_codigo_intermediario_ty1(){
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

    char* constroi_codigo_abstrato_ty1(char* nome){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(nome)  
                                                        + strlen("NameTy()") 
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "NameTy(");
        strcat(codigo_intermediario, nome);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_ty2(){
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

    char* constroi_codigo_abstrato_ty2(char* nome){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)  
                                                        + strlen(PARAMETRO2_CODIGO_INTERMEDIARIO) 
                                                        +strlen("TypeRecord(Fieldlist(,,)")
                                                        + strlen(nome)
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "TypeRecord(Fieldlist(");
        strcat(codigo_intermediario, nome);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ",");
        strcat(codigo_intermediario, PARAMETRO2_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_ty3(){
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

    char* constroi_codigo_abstrato_ty3(char* tipo){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(tipo)  
                                                        + strlen("ArrayTy()") 
                                                        + 1                                                                                                
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "ArrayTy(");
        strcat(codigo_intermediario, tipo);
        strcat(codigo_intermediario, ")");

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

    char* constroi_codigo_abstrato_tydec(char* nome){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)   
                                                        + strlen("TypeDec(,)\n  ")   
                                                        +strlen(nome)                                                
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "TypeDec(");
        strcat(codigo_intermediario, nome);
        strcat(codigo_intermediario, ",\n   ");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_dec_fundec(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)                                                      
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        // strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_abstrato_dec_fundec(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)  
                                                        + strlen("FunctionDec()")                                                    
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "FunctionDec(");
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_dec_tydec(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)                                                      
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        // strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_abstrato_dec_tydec(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)                                                      
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_dec_vardec(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)                                                      
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }
    
    char* constroi_codigo_abstrato_dec_vardec(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)                                                      
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);

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

    char* constroi_codigo_abstrato_expseq(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        1 /* \0 da string, indicando seu fim em C */
                                                        + strlen("\n SeqExp()")
                                                        // + strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)                                                                                                           
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, "\n SeqExp(");
        // strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);
        strcat(codigo_intermediario, ")");

        return codigo_intermediario;
    }

    char* constroi_codigo_intermediario_expseq1(){
        char* codigo_intermediario = (char*) malloc(                                                       
                                                        strlen(PARAMETRO1_CODIGO_INTERMEDIARIO)                                                                                                           
                                                        + 1 /* \0 da string, indicando seu fim em C */
                                                    );
        
        codigo_intermediario[0] = '\0';
        strcat(codigo_intermediario, PARAMETRO1_CODIGO_INTERMEDIARIO);

        return codigo_intermediario;
    }


