/*
////////////////////////////////////////////////////////////////////////////////
    Funcoes utilitarias
////////////////////////////////////////////////////////////////////////////////
*/
    char* busca_tipo_recursivo_ate_valor_primitivo(char* tipo_inicial);
    
    char* get_copia_string(char* string){
        char* copia_string = (char*) malloc (strlen(string)+1);
        strcpy(copia_string, string);
        return copia_string;
    }

    char* tipos_primitivos2[] = {"int", "string", "record"};
    
    int eh_tipo_primitivo_dif_de_array(char* tipo){
        int i = 0;

        for(i = 0; i < 3; i++){
            if(!strcmp(tipo,tipos_primitivos2[i])){
                return 1;
            }
        }

        return 0;
    }

    int eh_um_array(char* tipo){
        if(!strcmp(tipo,"array"))
            return 1;        
        return 0;
    }

    void escreveErro();

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

char CLASSE_TIPO[] = "type";
char CLASSE_VARIAVEL[] = "variable";
char CLASSE_PARAMETRO[] = "parameter";
char CLASSE_FUNCAO[] = "function";
char CLASSE_REGISTRO[] = "record";

