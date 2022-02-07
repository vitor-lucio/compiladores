#include "tabela.c"

/*
////////////////////////////////////////////////////////////////////////////////
    Funcoes de tratamento de erros
////////////////////////////////////////////////////////////////////////////////
*/

    void erro_de_tipagem_em_atribuicoes(){
        printf("**** Erro: Tipo declarado difere do tipo esperado! ****\n");
        exit(1);
    }

    void erro_de_tipagem_em_expressoes(){
        printf("**** Erro: Não é possível realizar essa operação para tipos distintos! ****\n");
        exit(1);
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
            printf("#### Erro: Não encontrei esse símbolo! ####\n");
            exit(1);
        }
    }

/*
////////////////////////////////////////////////////////////////////////////////
    Funcoes de checagem de tipos
////////////////////////////////////////////////////////////////////////////////
*/

    char* compara_e_define_um_tipo_binop(char* tipo_parametro_1, char* tipo_parametro_2){
        
        if(strcmp(tipo_parametro_1, tipo_parametro_2))
            erro_de_tipagem_em_expressoes();
        
        return tipo_parametro_1; 
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


