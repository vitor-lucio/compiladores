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

    void adiciona_simbolo_sem_verificacoes(struct simbolo *s){
        if(!tabela_simbolos.primeiro_elemento){
            tabela_simbolos.primeiro_elemento = s;
            tabela_simbolos.primeiro_elemento->next = NULL;

            printf("\nSIMBOLO ADICIONADO: %s %s\n", tabela_simbolos.primeiro_elemento->nome, tabela_simbolos.primeiro_elemento->tipo);
        }else{

            struct simbolo *iterador = tabela_simbolos.primeiro_elemento;
            
            while(iterador->next != NULL){
                iterador = iterador->next;
            }
            
            iterador->next = s;
            iterador->next->next = NULL;

            printf("\nSIMBOLO ADICIONADO: %s %s\n", iterador->next->nome, iterador->next->tipo);
        }
    }

    void atualiza_simbolo(struct simbolo *s, char* tipo, char* classe){
        s->tipo = get_copia_string(tipo);
        s->classe = get_copia_string(classe);
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



