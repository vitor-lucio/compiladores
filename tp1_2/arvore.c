#include "erros.c"

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
        char* classe;
        int num_arrays;
        int numero_de_parametros;
	};

    struct node* raiz_da_arvore; /* raiz da arvore */

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

        // printf("\n[    node pai: %s - %s ]\n", novo_node->codigo_intermediario, novo_node->tipo);
        // if(novo_node->node_filho1) printf("[ node filho1: %s - %s ]\n", novo_node->node_filho1->codigo_intermediario, novo_node->node_filho1->tipo);
        // if(novo_node->node_filho2) printf("[ node filho2: %s - %s ]\n", novo_node->node_filho2->codigo_intermediario, novo_node->node_filho2->tipo);
        // if(novo_node->node_filho3) printf("[ node filho3: %s - %s ]\n", novo_node->node_filho3->codigo_intermediario, novo_node->node_filho3->tipo);

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

