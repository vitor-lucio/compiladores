#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "gerais.c"

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
        char* bloco;    
        int numero_de_parametros;
        int temp;
        int label;

        struct simbolo *next;
        
    }simbolo;

    typedef struct tabela{
        struct simbolo *primeiro_elemento;
        int tamanho;
    }tabela;

    struct tabela tabela_simbolos;

/*
////////////////////////////////////////////////////////////////////////////////
    Funcoes da tabela de simbolo
////////////////////////////////////////////////////////////////////////////////
*/

    int pega_ultimo_temp(simbolo* simb){
        struct simbolo *iterador = tabela_simbolos.primeiro_elemento;

        if(iterador == NULL) return 0;
        
        while(iterador->next != NULL){
            if(!strcmp(iterador->nome, simb->nome) && !strcmp(iterador->classe, simb->classe) && !strcmp(iterador->bloco, simb->bloco)){                
                return iterador->temp;
            }
            iterador = iterador->next;
        }
        return iterador->temp+1;
    }

    int pega_ultimo_temp_de_todos(){
        struct simbolo *iterador = tabela_simbolos.primeiro_elemento;

        if(iterador == NULL) return 0;
        
        while(iterador->next != NULL){
            iterador = iterador->next;
        }

        return iterador->temp+1;
    }


    struct simbolo* inicializa_simbolo(char* nome, char* tipo, char* valor, char* classe, char* nivel, char* bloco){
        struct simbolo* novo_simbolo = (struct simbolo*) malloc (sizeof(struct simbolo));
        
        novo_simbolo->nome              = get_copia_string(nome);
        novo_simbolo->tipo              = get_copia_string(tipo);
        novo_simbolo->classe            = get_copia_string(classe);
        novo_simbolo->nivel             = get_copia_string(nivel);
        novo_simbolo->bloco             = get_copia_string(bloco);
        novo_simbolo->valor             = get_copia_string(valor);
        novo_simbolo->temp              = pega_ultimo_temp(novo_simbolo);

        return novo_simbolo;
    }

    
    void inicializa_tabela_simbolos(){
        tabela_simbolos.primeiro_elemento = NULL;
        tabela_simbolos.tamanho = 0;
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

    struct simbolo* busca_simbolo_de_tipo_pelo_nome(char* nome){
        struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
        
        while(iterador != NULL){
            if(!strcmp(iterador->classe, CLASSE_TIPO)){
                if(!strcmp(iterador->nome, nome)){
                    return iterador;
                }
            }
            
            iterador = iterador->next;
        }

        return NULL;
    }

    struct simbolo* busca_simbolo_por_classe_e_nome(char* nome, char* classe){
        struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
        
        while(iterador != NULL){
            if(!strcmp(iterador->classe, classe)){
                if(!strcmp(iterador->nome, nome)){
                    return iterador;
                }
            }
            
            iterador = iterador->next;
        }

        return NULL;
    }

    struct simbolo* busca_ultimo_simbolo_com_esse_nome(char* nome){
        // struct simbolo *iterador2 = tabela_simbolos.primeiro_elemento;
        // struct simbolo *aux2 = NULL;
        // int achei = 1;
        
        // while(iterador2 != NULL){         
        //     if(!strcmp(iterador2->nome, "begin")){
        //         aux2 = iterador2;                
        //     }
            
        //     iterador2 = iterador2->next;
        // }

        // struct simbolo *aux_do_aux2 = NULL;
        // if(aux2 != NULL){
        //     aux_do_aux2 = aux2;
        //     // printf("AU ENDIN AQ %s %d\n", aux2->nome, aux2->numero_de_parametros);
        // // while(aux2 != NULL){
        //     aux2 = aux2->next;
        //     int n = aux2->numero_de_parametros;
          
        //     while(aux2->next != NULL && !strcmp(aux2->next->nome,nome)){
        //         // if(i == n){
        //             printf("OIAAAA %s\n", aux2->next->nome);
        //             if(!strcmp(aux2->next->nome,nome)){
                     
        //                 return aux2->next;
        //             }
        //         // }
        //         aux2 = aux2->next;
        //     }
        // }

        struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
        struct simbolo *aux = NULL;
        
        while(iterador != NULL){         
            if(!strcmp(iterador->nome, nome)){
                aux = iterador;
            }
            
            iterador = iterador->next;
        }
        
        return aux;
        // return NULL;


    }

    struct simbolo* busca_simbolo_por_classe_e_nome_e_bloco(char* nome, char* classe,char* bloco){
        struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
        
        while(iterador != NULL){
            if(!strcmp(iterador->classe, classe)){
                if(!strcmp(iterador->nome, nome)){
                    if(!strcmp(iterador->bloco, bloco)){
                        return iterador;
                    }
                }
            }
            
            iterador = iterador->next;
        }

        return NULL;
    }

    simbolo* busca_simbolo_recursivamente(char* tipo_inicial){
        simbolo* simbolo_encontrado = busca_simbolo_de_tipo_pelo_nome(tipo_inicial);

        while(simbolo_encontrado != NULL){
            if(eh_tipo_primitivo(simbolo_encontrado->tipo)) break;
            simbolo_encontrado = busca_simbolo_de_tipo_pelo_nome(simbolo_encontrado->tipo);
        }

        return simbolo_encontrado;
    }

    void adiciona_simbolo(struct simbolo *s){
        if(!tabela_simbolos.primeiro_elemento){
            tabela_simbolos.primeiro_elemento = s;
            tabela_simbolos.primeiro_elemento->next = NULL;
            tabela_simbolos.tamanho++;
            // printf("\nSIMBOLO ADICIONADO: %s %s\n", tabela_simbolos.primeiro_elemento->nome, tabela_simbolos.primeiro_elemento->tipo);
        }else{

            if(busca_simbolo(s)){
                // printf("\nSIMBOLO %s JA EXISTE!\n", s->nome);
                return;
            }

            struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
            
            while(iterador->next != NULL){
                iterador = iterador->next;
            }
            
            iterador->next = s;
            iterador->next->next = NULL;
            tabela_simbolos.tamanho++;
            // printf("\nSIMBOLO ADICIONADO: %s %s\n", iterador->next->nome, iterador->next->tipo);
        }
    }

    void adiciona_simbolo_sem_verificacoes(struct simbolo *s){
        if(!tabela_simbolos.primeiro_elemento){
            tabela_simbolos.primeiro_elemento = s;
            tabela_simbolos.primeiro_elemento->next = NULL;
            tabela_simbolos.tamanho++;
            // printf("\nSIMBOLO ADICIONADO: %s %s\n", tabela_simbolos.primeiro_elemento->nome, tabela_simbolos.primeiro_elemento->tipo);
        }else{

            struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
            
            while(iterador->next != NULL){
                iterador = iterador->next;
            }
            
            iterador->next = s;
            iterador->next->next = NULL;
            tabela_simbolos.tamanho++;
            // printf("\nSIMBOLO ADICIONADO: %s %s\n", iterador->next->nome, iterador->next->tipo);
        }
    }

    void atualiza_simbolo(struct simbolo *s, char* tipo, char* classe){
        s->tipo = get_copia_string(tipo);
        s->classe = get_copia_string(classe);
    }

    void imprime_tabela_simbolos(){
        struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
        
        printf("|    NOME   |    TIPO   |   VALOR   |   CLASSE  |   BLOCO   |  NUM DE PARAM  |  ROTULO  |");
        printf("\nx-----------x-----------x-----------x-----------x-----------x----------------x----------x");
        
        while(iterador != NULL){
            // if(strcmp(iterador->nome,"-"))                    t%d  L%d    
                printf("\n|%10s |%10s |%10s |%10s |%10s | %14d |", iterador->nome, iterador->tipo, 
                                                    iterador->valor, iterador->classe, 
                                                    iterador->bloco, iterador->numero_de_parametros);
                                                    // iterador->temp, iterador->label);
                if(!strcmp(iterador->classe, CLASSE_VARIAVEL) || !strcmp(iterador->classe, CLASSE_PARAMETRO))
                    printf("  %5s%-2d |", "t",iterador->temp);
                else if(!strcmp(iterador->classe, CLASSE_FUNCAO))
                    printf("  %5s%-2d |", "L",iterador->label);
                else
                    printf("  %7s |"," ");
            iterador = iterador->next;
        }

        printf("\n");
    }

    void imprime_tabela_rotulos(){
        struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
        
        while(iterador != NULL){

            if(!strcmp(iterador->classe,CLASSE_VARIAVEL)){
                printf("%-10s %-10s esta associada a t%-2d\n", "Variavel", iterador->nome, iterador->temp);
            }
            if(!strcmp(iterador->classe,CLASSE_PARAMETRO)){
                printf("%-10s %-10s esta associado a t%-2d\n", "Parametro", iterador->nome, iterador->temp);
            }
            if(!strcmp(iterador->classe,CLASSE_FUNCAO)){
                printf("%-10s %-10s esta associada a L%-2d\n", "Funcao", iterador->nome, iterador->label);
            }

            iterador = iterador->next;
        }

        printf("\n");
    }

    void atualiza_classe_e_esc_simbolos_n_posicoes_a_frente(simbolo* simb, int n, char* classe){
        
        simbolo* iterador = tabela_simbolos.primeiro_elemento;
        
        for(int i = 0; i < tabela_simbolos.tamanho; i++){
            if(!strcmp(iterador->nome, simb->nome)){
                for(int j = 0; j < n; j++){                    
                    iterador = iterador->next;
                    iterador->classe = classe;
                    iterador->bloco = simb->nome;
                }    
                return;    
            }

            iterador = iterador->next;
        }
    }

    int procura_simb_nas_n_posicoes_a_frente(simbolo* func, char* param){

        simbolo* iterador = tabela_simbolos.primeiro_elemento;
        
        for(int i = 0; i < tabela_simbolos.tamanho; i++){
            if(!strcmp(iterador->nome, func->nome)){
                for(int j = 0; j < func->numero_de_parametros; j++){
                    iterador = iterador->next;
                    if(!strcmp(iterador->nome, param)){
                        return 1;
                    }
                }    
                return 0;    
            }
            iterador = iterador->next;
        }

        return 0;
    }

    int procura_simb_nos_simbolos_globais(char* valor){

        simbolo* iterador = tabela_simbolos.primeiro_elemento;
        
        for(int i = 0; i < tabela_simbolos.tamanho; i++){
            if(!strcmp(iterador->nome, valor)){
                if(!strcmp(iterador->bloco, "?")){
                    return 1;
                }                  
                return 0; 
            }
            iterador = iterador->next;
        }
        return 0;
    }


