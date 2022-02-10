#include "tabela.c"

 int linha = 0;
/*
////////////////////////////////////////////////////////////////////////////////
    Funcoes de tratamento de erros
////////////////////////////////////////////////////////////////////////////////
*/

    void erro_de_tipagem_em_atribuicoes(){
        printf("\n==================================================================\n\n");
        printf("**** Erro: Tipo declarado difere do tipo esperado! ****\n");
        escreveErro();
    }

    void erro_de_tipagem_em_expressoes(){
        printf("\n==================================================================\n\n");
        printf("**** Erro: Não é possível realizar essa operação para tipos distintos! ****\n");
        escreveErro();
    }

    void erro_de_nao_inteiro_em_expressoes(){
        printf("\n==================================================================\n\n");
        printf("**** Erro: Não é possível realizar essa operação para tipos diferentes de inteiro! ****\n");
        escreveErro();
    }
    
    void erro_de_tipagem_parametros_funcoes(){

    }

    void erro_de_redeclaracao_de_simbolo(){

    }

    void erro_de_simbolo_nao_declarado(){

    }

    void erro_de_tipagem_em_arrays(){

    }

    void erro_de_tipagem_em_registros(){

    }

    void erro_de_tipagem_tipos_recursivos(){

    }

    void erro_simbolo_nulo_possivel_de_segfault(simbolo* simbolo_encontrado){
        if(simbolo_encontrado == NULL){
            printf("\n==================================================================\n\n");
            printf("**** Erro: Símbolo não declarado! ****\n");
            escreveErro();
        }
    }

/*
////////////////////////////////////////////////////////////////////////////////
    Funcoes de checagem de tipos
////////////////////////////////////////////////////////////////////////////////
*/

    char* compara_e_define_um_tipo_binop(char* tipo_parametro_1, char* tipo_parametro_2){
        
        char* string_tipo_1 = tipo_parametro_1;
        char* string_tipo_2 = tipo_parametro_2;
        
        if(!eh_tipo_primitivo(tipo_parametro_1)){
            string_tipo_1 = busca_tipo_recursivo_ate_valor_primitivo(tipo_parametro_1);
        }
            
        if(!eh_tipo_primitivo(tipo_parametro_2)){
            string_tipo_2 = busca_tipo_recursivo_ate_valor_primitivo(tipo_parametro_2);
        }
        
        if(!strcmp(string_tipo_1, string_tipo_2)){
            if(!strcmp(string_tipo_1, "int"))
                return tipo_parametro_1;
            else
                erro_de_nao_inteiro_em_expressoes();
        }            
        
        erro_de_tipagem_em_expressoes();
    }
  
    char* testinho(char* nome_parametro_1, char* nome_parametro_2, char* tipo_parametro_1, char* tipo_parametro_2){
        
        simbolo* simbolo_param_1 = busca_ultimo_simbolo_com_esse_nome(nome_parametro_1);
        simbolo* simbolo_param_2 = busca_ultimo_simbolo_com_esse_nome(nome_parametro_2);
        
        if(!simbolo_param_1 && !simbolo_param_2) 
            return compara_e_define_um_tipo_binop(tipo_parametro_1, tipo_parametro_2);
        if(!simbolo_param_1) return compara_e_define_um_tipo_binop(tipo_parametro_1, simbolo_param_2->tipo);
        if(!simbolo_param_2) return compara_e_define_um_tipo_binop(simbolo_param_1->tipo, tipo_parametro_2);
    
        return compara_e_define_um_tipo_binop(simbolo_param_1->tipo, simbolo_param_2->tipo);
    }

    char* busca_tipo_recursivo_ate_valor_primitivo(char* tipo_inicial){
        
        simbolo* simbolo_encontrado = busca_simbolo_recursivamente(tipo_inicial);
        erro_simbolo_nulo_possivel_de_segfault(simbolo_encontrado);

        if(eh_um_array(simbolo_encontrado->tipo)){
            if(eh_tipo_primitivo(simbolo_encontrado->valor))
                return simbolo_encontrado->valor;                       
            return busca_tipo_recursivo_ate_valor_primitivo(simbolo_encontrado->valor);          
        }
        
        return simbolo_encontrado->tipo;
    } 

    char* busca_tipo_recursivo_ate_tipo_primitivo(char* tipo_inicial){

        if(eh_tipo_primitivo(tipo_inicial))
            return tipo_inicial;
        
        simbolo* simbolo_encontrado = busca_simbolo_recursivamente(tipo_inicial);
        erro_simbolo_nulo_possivel_de_segfault(simbolo_encontrado);

        if(eh_tipo_primitivo(simbolo_encontrado->tipo))           
            return simbolo_encontrado->tipo;         
        return busca_tipo_recursivo_ate_valor_primitivo(simbolo_encontrado->tipo); 
    } 

    char* compara_e_define_um_tipo(char* tipo_parametro_1, char* tipo_parametro_2){

        char* string_tipo_1 = tipo_parametro_1;
        char* string_tipo_2 = tipo_parametro_2;

        if(!eh_tipo_primitivo(tipo_parametro_1)){
            string_tipo_1 = busca_tipo_recursivo_ate_valor_primitivo(tipo_parametro_1);
        }
            
        if(!eh_tipo_primitivo(tipo_parametro_2)){
            string_tipo_2 = busca_tipo_recursivo_ate_valor_primitivo(tipo_parametro_2);
        }

        if(!strcmp(string_tipo_1, string_tipo_2))
            return tipo_parametro_1;
        
        erro_de_tipagem_em_atribuicoes();
    }     

    char* busca_e_define_tipo(char* tipo_parametro){ 

        simbolo* simbolo_encontrado = busca_simbolo_de_tipo_pelo_nome(tipo_parametro);

        while(simbolo_encontrado != NULL){
            if(eh_tipo_primitivo(simbolo_encontrado->tipo)) break;
            simbolo_encontrado = busca_simbolo_de_tipo_pelo_nome(simbolo_encontrado->tipo);
        }

        return tipo_parametro;
    }     
    
    int pega_num_arrays_aninhados(char* tipo_inicial, int num){

        simbolo* simbolo_encontrado = busca_simbolo_recursivamente(tipo_inicial);

        if(simbolo_encontrado){
            if(eh_um_array(simbolo_encontrado->tipo)){
                if(eh_tipo_primitivo(simbolo_encontrado->valor)) return num+1;        
                return pega_num_arrays_aninhados(simbolo_encontrado->valor, num + 1);          
            }
        }

        return num;
    } 


