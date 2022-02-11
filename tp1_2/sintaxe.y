%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include "lex.yy.c"
    #include "arvore.c"
    
    void yyerror(const char *s);
    int yylex();
    int yywrap();

    int erroEncontrado = 0;
  
    int caractere = 0;
    char* arquivo;

    int labelAtual = 0;
    // int close = 0;
                                                                                                      
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
                                                                        $$.node->tipo = compara_e_define_um_tipo(($1.node)->tipo, ($3.node)->tipo); 
                                                                        $$.node->nome = $$.node->tipo;                                                                     
                                                                        printf("exp -> exp + exp\n"); 
                                                                    } /* BINOP(MAIS, exp, exp) */
    | exp MENOS exp                                                 {
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                                                        $$.node->tipo = compara_e_define_um_tipo(($1.node)->tipo, ($3.node)->tipo);                                                                        
                                                                        printf("exp -> exp - exp\n"); 
                                                                    } /* BINOP(MENOS, exp, exp) */
    | exp MULTIPLICACAO exp                                         {
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                                                        // Funcionando para declaracao de variavel com multiplicacao                                                                                                                   
                                                                        $$.node->tipo = compara_e_define_um_tipo_binop(($1.node)->tipo, ($3.node)->tipo);        
                                                                        $$.node->nome = $$.node->tipo;        
                                                                        printf("exp -> exp * exp\n"); 
                                                                    } /* BINOP(MULTIPLICACAO, exp, exp) */
    | exp DIVISAO exp                                               {
                                                                        $$.node = inicializa_node($1.node, $3.node, NULL, constroi_codigo_intermediario_binop($2));
                                                                        $$.node->tipo = testinho(($1.node)->nome, ($3.node)->nome, ($1.node)->tipo, ($3.node)->tipo);     
                                                                        $$.node->nome = $$.node->tipo;                                                                        
                                                                        printf("exp -> exp / exp\n"); 
                                                                    } /* BINOP(DIVISAO, exp, exp) */

    | MENOS exp                                                     { 
                                                                        $$.node = inicializa_node($2.node, NULL, NULL, "TODO");
                                                                        printf("exp -> - exp\n"); 
                                                                    } /* CONST(- exp) */
    | NUMERO                                                        {
                                                                        $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_const($1));
                                                                        $$.node->tipo = "int";
                                                                        $$.node->nome = "int";
                                                                        $$.node->num_arrays = 0;
                                                                        printf("exp -> num\n");
                                                                    } /* CONST(NUMERO) */
    | STRING_CONSTANTE                                              { 
                                                                        $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_const($1));
                                                                        $$.node->tipo = "string";
                                                                        $$.node->nome = "string";
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
                                                                        $$.node->tipo = "record";
                                                                        printf("exp -> type-id { id = exp idexps }\n"); 
                                                                    }
    | type_id ABRE_COLCHETE exp FECHA_COLCHETE OF exp               { 
                                                                        
                                                                        simbolo* expr = busca_simbolo_por_classe_e_nome(($3.node)->nome, "variable");
                                                                        if(expr){                                                                            
                                                                            if(strcmp(expr->tipo, "int")){
                                                                                printf("\n==================================================================\n\n"); 
                                                                                printf("**** Erro: Tamanho do array deve ser do tipo inteiro! ****\n");
                                                                                escreveErro();
                                                                            }
                                                                            $$.node = inicializa_node($1.node, $3.node, $6.node, constroi_codigo_intermediario_call3(expr->temp));
                                                                        }else{
                                                                            if(strcmp(($3.node)->nome, "int")){
                                                                                printf("\n==================================================================\n\n"); 
                                                                                printf("**** Erro: Tamanho do array deve ser do tipo inteiro! ****\n");
                                                                                escreveErro();
                                                                            }
                                                                            $$.node = inicializa_node($1.node, $3.node, $6.node, constroi_codigo_intermediario_call1());
                                                                        }


                                                                        if(strcmp(($1.node)->tipo, "array") && eh_tipo_primitivo(($1.node)->valor)){
                                                                            printf("\n==================================================================\n\n"); 
                                                                            printf("**** Erro: O tipo não é um array na atribuicao! ****\n");
                                                                            escreveErro();
                                                                        }
                                                                        
                                                                        if(eh_tipo_primitivo(($6.node)->tipo) && strcmp(($6.node)->tipo, "array")){
                                                                            if(strcmp(busca_tipo_recursivo_ate_tipo_primitivo(($1.node)->valor), "array")){
                                                                                printf("\n==================================================================\n\n"); 
                                                                                printf("**** Erro: tipo a esquerda deveria ser um array! ****\n");
                                                                                escreveErro();
                                                                            }

                                                                            if(strcmp(busca_tipo_recursivo_ate_valor_primitivo(($1.node)->valor), ($6.node)->tipo)){
                                                                                printf("\n==================================================================\n\n"); 
                                                                                printf("**** Erro: tipo do array inválido! ****\n");
                                                                                escreveErro();
                                                                            }

                                                                            if(pega_num_arrays_aninhados(($1.node)->valor, 0) > 1){
                                                                                printf("\n==================================================================\n\n"); 
                                                                                printf("**** Erro: quantidade de arrays diferentes! ****\n");
                                                                                escreveErro();
                                                                            }

                                                                            // printf("NUM DE ARRAYS: %s %d\n", ($1.node)->valor, pega_num_arrays_aninhados(($1.node)->valor, 0)-1); 
                                                                            // printf("NUM DE ARRAYS: %s %d\n", ($6.node)->tipo, ($6.node)->num_arrays);

                                                                            $$.node->num_arrays = pega_num_arrays_aninhados(($1.node)->valor, 0);
                                                                            $$.node->tipo = ($1.node)->valor;                                                                        
                                                                         
                                                                        }else{
                                                                            if(strcmp(busca_tipo_recursivo_ate_valor_primitivo(($1.node)->valor), busca_tipo_recursivo_ate_valor_primitivo(($6.node)->tipo))){
                                                                                printf("\n==================================================================\n\n"); 
                                                                                printf("**** Erro: tipos dos arrays não batem! ****\n");
                                                                                escreveErro();
                                                                            }else{
                                                                                // printf("NUM DE ARRAYS: %s %d\n", ($1.node)->valor, pega_num_arrays_aninhados(($1.node)->valor, 0)-1); 
                                                                                // printf("NUM DE ARRAYS: %s %d\n", ($6.node)->tipo, ($6.node)->num_arrays);                                                                               
                                                                               
                                                                                if(pega_num_arrays_aninhados(($1.node)->valor, 0)-1 == ($6.node)->num_arrays){
                                                                                    $$.node->num_arrays = pega_num_arrays_aninhados(($1.node)->valor, 0);
                                                                                }else{
                                                                                    printf("\n==================================================================\n\n"); 
                                                                                    printf("**** Erro: quantidade de arrays diferentes! ****\n");
                                                                                    escreveErro();
                                                                                }
                                                                                $$.node->tipo = ($1.node)->valor;
                                                                            }
                                                                        }

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
                                                                        $$.node->tipo = get_copia_string(($1.node)->tipo); 
                                                                        $$.node->nome = get_copia_string(($1.node)->nome);
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
                    simbolo* simbolo_encontrado = busca_ultimo_simbolo_com_esse_nome($1);
                    if(simbolo_encontrado){
                        printf("OLAAA\n");
                        $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_temp(simbolo_encontrado->temp));                                                        
                    }else{
                        $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_temp(pega_ultimo_temp_de_todos()));  
                    }

                    $$.node->valor = get_copia_string($1); 
                    $$.node->nome = get_copia_string($1);

                    if(simbolo_encontrado){
                        $$.node->tipo = simbolo_encontrado->tipo;                                                                                                             
                    }else{
                        $$.node->tipo = get_copia_string($1);  
                    }                                                                                

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
                                                    $$.node = inicializa_node($2.node, $3.node, NULL, constroi_codigo_intermediario_expseq1());
                                                    printf("expseq1 -> ; exp expseq1\n"); 
                                                } /* Nenhum código intermediário neste nó */
    |                                           { 
                                                    $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_vazio());
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
                                                            printf("------------- Node de 'variavel : tipo' -------------\n");
                                                            $$.node->numero_de_parametros = ($4.node)->numero_de_parametros + 1;
                                                            
                                                            simbolo* simbolo_encontrado = busca_simbolo_por_classe_e_nome($1, CLASSE_PARAMETRO);
                                                            if(simbolo_encontrado){
                                                                printf("**** Variavel \"%s\" ja foi declarada na tabela de simbolos, mas em outra funcao! ****\n", simbolo_encontrado->nome);
                                                            }
                                                            
                                                            simbolo_encontrado = busca_simbolo_pelo_nome($1);
                                                            if(simbolo_encontrado == NULL){
                                                                printf("\n==================================================================\n\n");
                                                                printf("######### tyfields: Valor NULL #########");
                                                                escreveErro();
                                                            }
                                                            /*
                                                                Verifica se precisamos atualizar um simbolo existente,
                                                                ou criar outro (em casos onde o simbolo existente é de outra classe)
                                                            */
                                                            if(!strcmp(simbolo_encontrado->classe, "?")){
                                                                atualiza_simbolo(simbolo_encontrado, ($3.node)->valor, CLASSE_PARAMETRO);
                                                            }else{
                                                                simbolo* novo_simbolo = inicializa_simbolo(simbolo_encontrado->nome, ($3.node)->valor, "?", CLASSE_PARAMETRO, "?", "?");
                                                                adiciona_simbolo_sem_verificacoes(novo_simbolo);
                                                            } 

                                                            printf("tyfields -> id : type-id tyfields1\n"); 
                                                        }
    |                                                   { 
                                                            $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_tyfields2());
                                                            $$.node->numero_de_parametros = 0;
                                                            printf("tyfields -> \n"); 
                                                        }
    ;   

/**/
tyfields1: 
      VIRGULA VARIAVEL DOIS_PONTOS type_id tyfields1        { 
                                                                $$.node = inicializa_node($4.node, $5.node, NULL, constroi_codigo_intermediario_tyfields11());
                                                                printf("------------- Node de ', variavel : tipo' -------------\n");
                                                                $$.node->numero_de_parametros = ($5.node)->numero_de_parametros + 1;

                                                                simbolo* simbolo_encontrado = busca_simbolo_por_classe_e_nome($2, CLASSE_PARAMETRO);
                                                                if(simbolo_encontrado){
                                                                    printf("**** Variavel \"%s\" ja foi declarada na tabela de simbolos, mas em outro bloco! ****\n", simbolo_encontrado->nome);
                                                                }

                                                                simbolo_encontrado = busca_simbolo_por_classe_e_nome($2, "var rec");
                                                                if(simbolo_encontrado){
                                                                    printf("**** Variavel \"%s\" ja foi declarada na tabela de simbolos, mas em outro bloco! ****\n", simbolo_encontrado->nome);
                                                                }
                                                                
                                                                simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                                if(simbolo_encontrado == NULL){
                                                                    printf("\n==================================================================\n\n");
                                                                    printf("######### tyfields1: Valor NULL #########\n");
                                                                    escreveErro();
                                                                }
                                                                /*
                                                                    Verifica se precisamos atualizar um simbolo existente,
                                                                    ou criar outro (em casos onde o simbolo existente é de outra classe)
                                                                */
                                                                if(!strcmp(simbolo_encontrado->classe, "?")){
                                                                    atualiza_simbolo(simbolo_encontrado, ($4.node)->valor, "?");
                                                                }else{
                                                                    simbolo* novo_simbolo = inicializa_simbolo(simbolo_encontrado->nome, ($4.node)->valor, "?", "?", "?", "?");
                                                                    adiciona_simbolo_sem_verificacoes(novo_simbolo);
                                                                } 
                                                            
                                                                printf("tyfields1 -> , id : type-id tyfields1\n"); 
                                                            }
    |                                                       { 
                                                                $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_tyfields12());
                                                                $$.node->numero_de_parametros = 0;
                                                                printf("tyfields1 -> \n"); 
                                                            }
    ;

/**/
ty: 
      VARIAVEL                                                          {  
                                                                            $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_ty1()); 
                                                                            $$.node->tipo = $1;                                                                           
                                                                            printf("ty -> id\n"); 
                                                                        }
    | ABRE_CHAVES VARIAVEL DOIS_PONTOS type_id tyfields1 FECHA_CHAVES   {   
                                                                            $$.node = inicializa_node($4.node, $5.node, NULL, constroi_codigo_intermediario_ty2());                                                        
                                                                            printf("------------- Node do corpo do record -------------\n");
                                                                            $$.node->tipo = "record";
                                                                            $$.node->numero_de_parametros = ($5.node)->numero_de_parametros + 1;

                                                                            simbolo* simbolo_encontrado = busca_simbolo_por_classe_e_nome($2, CLASSE_PARAMETRO);
                                                                            if(simbolo_encontrado){
                                                                                printf("**** Variavel \"%s\" ja foi declarada na tabela de simbolos, mas em outro bloco! ****\n", simbolo_encontrado->nome);
                                                                            }

                                                                            simbolo_encontrado = busca_simbolo_por_classe_e_nome($2, "var rec");
                                                                            if(simbolo_encontrado){
                                                                                printf("**** Variavel \"%s\" ja foi declarada na tabela de simbolos, mas em outro bloco! ****\n", simbolo_encontrado->nome);
                                                                            }
                                                                            
                                                                            simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                                            if(simbolo_encontrado == NULL){
                                                                                printf("\n==================================================================\n\n");
                                                                                printf("######### ty: Valor NULL #########\n");
                                                                                escreveErro();
                                                                            }
                                                                            /*
                                                                                Verifica se precisamos atualizar um simbolo existente,
                                                                                ou criar outro (em casos onde o simbolo existente é de outra classe)
                                                                            */
                                                                            if(!strcmp(simbolo_encontrado->classe, "?")){
                                                                                atualiza_simbolo(simbolo_encontrado, ($4.node)->valor, "var rec");
                                                                            }else{
                                                                                simbolo* novo_simbolo = inicializa_simbolo(simbolo_encontrado->nome, ($4.node)->valor, "?", "var rec", "?", "?");
                                                                                adiciona_simbolo_sem_verificacoes(novo_simbolo);
                                                                            }                                                                                                                            
                                                                                                                                            
                                                                            printf("ty -> { id : type-id tyfields1 }\n"); 
                                                                        }
    | ARRAY OF VARIAVEL                                                 { 
                                                                            $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_ty3());                                                        
                                                                            $$.node->tipo = "array";
                                                                            // $$.node->tipo = busca_e_define_tipo(($3));
                                                                            $$.node->valor = get_copia_string($3);
                                                                            printf("ty -> array of id\n"); 
                                                                        }
    ;

/**/
tydec: 
      TYPE VARIAVEL IGUAL ty                            { 
                                                            $$.node = inicializa_node($4.node, NULL, NULL, constroi_codigo_intermediario_tydec());
                                                            
                                                            simbolo* simbolo_encontrado = busca_simbolo_por_classe_e_nome($2, CLASSE_TIPO);
                                                            if(simbolo_encontrado){
                                                                printf("\n==================================================================\n\n");
                                                                printf("**** Tipo \"%s\" ja foi declarado na tabela de simbolos! ****\n", simbolo_encontrado->nome);
                                                                escreveErro();
                                                            }
                                                            
                                                            simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                            if(simbolo_encontrado == NULL){
                                                                printf("\n==================================================================\n\n");
                                                                printf("######### tydec: Valor NULL #########");
                                                                escreveErro();
                                                            }
                                                            /*
                                                                Verifica se precisamos atualizar um simbolo existente,
                                                                ou criar outro (em casos onde o simbolo existente é de outra classe)
                                                            */
                                                            if(!strcmp(simbolo_encontrado->classe, "?")){
                                                                if(!strcmp(($4.node)->tipo, "array")){
                                                                    simbolo_encontrado->valor = get_copia_string(($4.node)->valor);
                                                                    printf("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n Array detectado na atualizacao de tipo na tabela %s\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n", ($4.node)->tipo);
                                                                }

                                                                atualiza_simbolo(simbolo_encontrado, ($4.node)->tipo, CLASSE_TIPO);                                                                 
                                                                simbolo_encontrado->numero_de_parametros = ($4.node)->numero_de_parametros;                                                                
                                                                if(!strcmp(($4.node)->tipo,"record")) atualiza_classe_e_esc_simbolos_n_posicoes_a_frente(simbolo_encontrado, simbolo_encontrado->numero_de_parametros, "var rec");
                                                            }
                                                            else{
                                                                struct simbolo* novo_simbolo = inicializa_simbolo(simbolo_encontrado->nome, ($4.node)->tipo, "?", CLASSE_TIPO, "?", "?");

                                                                if(!strcmp(($4.node)->tipo, "array")){
                                                                    novo_simbolo->valor = get_copia_string(($4.node)->valor);
                                                                    printf("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n Array detectado na criacao de registro de tipo na tabela %s\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n", ($4.node)->tipo);
                                                                }

                                                                adiciona_simbolo_sem_verificacoes(novo_simbolo);
                                                                novo_simbolo->numero_de_parametros = ($4.node)->numero_de_parametros;
                                                                if(!strcmp(($4.node)->tipo,"record")) atualiza_classe_e_esc_simbolos_n_posicoes_a_frente(novo_simbolo, novo_simbolo->numero_de_parametros, "var rec"); 
                                                            }       
                                           
                                                            printf("tydec -> type id = ty\n"); 
                                                        }
    ;

/**/
vardec: 
      VAR VARIAVEL ATRIBUICAO exp                       {                                                             
                                                            printf("------------- Node da declaracao de variavel -------------\n");
                                                            struct simbolo *simbolo_encontrado = busca_simbolo_por_classe_e_nome($2, CLASSE_VARIAVEL);
                                                            if(simbolo_encontrado){
                                                                printf("\n==================================================================\n\n");
                                                                printf("**** Variavel \"%s\" ja foi declarado na tabela de simbolos ****\n", simbolo_encontrado->nome);
                                                                escreveErro();
                                                            }                                                            
                                                            
                                                            simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                            if(simbolo_encontrado == NULL){
                                                                printf("\n==================================================================\n\n");
                                                                printf("######### vardec: Valor NULL #########");
                                                                escreveErro();
                                                            }
                                                            
                                                            /*
                                                                Verifica se precisamos atualizar um simbolo existente,
                                                                ou criar outro (em casos onde o simbolo existente é de outra classe)
                                                            */

                                                            if(!strcmp(simbolo_encontrado->classe, "?")){
                                                                atualiza_simbolo(simbolo_encontrado, busca_e_define_tipo(($4.node)->tipo), CLASSE_VARIAVEL);                                                                
                                                                $$.node = inicializa_node($4.node, NULL, NULL, constroi_codigo_intermediario_vardec1(simbolo_encontrado->temp));                                                        
                                                            }
                                                            else{
                                                                struct simbolo* novo_simbolo = inicializa_simbolo(simbolo_encontrado->nome, busca_e_define_tipo(($4.node)->tipo), "?", CLASSE_VARIAVEL, "?", "?");
                                                                adiciona_simbolo_sem_verificacoes(novo_simbolo);
                                                                $$.node = inicializa_node($4.node, NULL, NULL, constroi_codigo_intermediario_vardec1(novo_simbolo->temp));  
                                                            }                                                                                                                                                                                   

                                                            printf("vardec -> var id := exp\n"); 
                                                        }
    | VAR VARIAVEL DOIS_PONTOS type_id ATRIBUICAO exp   {  
                                                            printf("------------- Node da declaracao de variavel -------------\n");
                                                            simbolo *simbolo_encontrado = busca_simbolo_por_classe_e_nome($2, CLASSE_VARIAVEL);
                                                            if(simbolo_encontrado){
                                                                printf("**** Variavel \"%s\" ja foi declarado na tabela de simbolos! ****\n", simbolo_encontrado->nome);
                                                                escreveErro();
                                                            }

                                                            simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                            if(simbolo_encontrado == NULL){
                                                                printf("\n==================================================================\n\n");
                                                                printf("######### vardec: Valor NULL #########");
                                                                escreveErro();
                                                            }

                                                            /*
                                                                Verifica se precisamos atualizar um simbolo existente,
                                                                ou criar outro (em casos onde o simbolo existente é de outra classe)
                                                            */
                                                            
                                                            if(!strcmp(simbolo_encontrado->classe, "?")){
                                                                atualiza_simbolo(simbolo_encontrado, compara_e_define_um_tipo(($4.node)->valor, ($6.node)->tipo), CLASSE_VARIAVEL);
                                                                $$.node = inicializa_node($4.node, $6.node, NULL, constroi_codigo_intermediario_vardec2(simbolo_encontrado->temp));                                                        
                                                            }else{
                                                                simbolo* novo_simbolo = inicializa_simbolo(simbolo_encontrado->nome, compara_e_define_um_tipo(($4.node)->valor, ($6.node)->tipo), "?", CLASSE_VARIAVEL, "?", "?");
                                                                adiciona_simbolo_sem_verificacoes(novo_simbolo);
                                                                $$.node = inicializa_node($4.node, $6.node, NULL, constroi_codigo_intermediario_vardec2(novo_simbolo->temp));  
                                                            }
                                                            /**/                                                                                                                           
                                                            if(pega_num_arrays_aninhados(($4.node)->valor,0) != pega_num_arrays_aninhados(($6.node)->tipo,0)){
                                                                printf("\n==================================================================\n\n");
                                                                printf("**** Erro: quantidade de arrays diferentes! ****\n");
                                                                escreveErro();
                                                            }

                                                            printf("vardec -> var id : type-id := exp\n");
                                                        }
    ;

/**/
fundec: 
      FUNCTION VARIAVEL ABRE_PARENTESES tyfields FECHA_PARENTESES IGUAL exp                     { 
                                                                                                    $$.node = inicializa_node($4.node, $7.node, NULL, constroi_codigo_intermediario_fundec2());


                                                                                                    printf("------------- Node da funcao -------------\n");
                                                                                                    simbolo* simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                                                                    simbolo_encontrado->numero_de_parametros = ($4.node)->numero_de_parametros;  
                                                                                                    simbolo_encontrado->label = labelAtual;   
                                                                                                    labelAtual++;
                                                                                                      
                                                                                                    char t[10];
                                                                                                    sprintf(t,"%d",simbolo_encontrado->label);
                                                                                                    char* temp = get_copia_string(codigo_intermediario_funcao);
                                                                                                    char* temp2 = get_copia_string(monta_codigo_intermediario_da_arvore($7.node));                                                                                                    
                                                                                                    codigo_intermediario_funcao = (char*)malloc(strlen(temp)+strlen(temp2)+strlen("\n")
                                                                                                                                                +strlen("L:\n")+strlen(t));
                                                                                                    strcat(codigo_intermediario_funcao, temp);
                                                                                                    strcat(codigo_intermediario_funcao, "\n\nL");
                                                                                                    strcat(codigo_intermediario_funcao, t);
                                                                                                    strcat(codigo_intermediario_funcao, ":");
                                                                                                    strcat(codigo_intermediario_funcao, "\n");
                                                                                                    strcat(codigo_intermediario_funcao, temp2);
                                                                                                    
                                                                                                    atualiza_classe_e_esc_simbolos_n_posicoes_a_frente(simbolo_encontrado, simbolo_encontrado->numero_de_parametros, "parameter");                                                                                                                        
                                                                                                    atualiza_simbolo(simbolo_encontrado, "void", CLASSE_FUNCAO);      
                                                                                                   
                                                                                                    if(!procura_parametros_da_funcao_na_arvore(simbolo_encontrado, $7.node)){
                                                                                                        printf("\n==================================================================\n\n");
                                                                                                        printf("**** Erro: funcao %s, chama simbolos invalidos! ****\n", $2);                                                                                                   
                                                                                                        escreveErro();
                                                                                                    }

                                                                                                    printf("fundec -> function id ( tyfields ) = exp\n");  
                                                                                                    // struct simbolo* novo_simbolo2 = inicializa_simbolo("end", "?", "?", "?", "?", "?");
                                                                                                    // adiciona_simbolo_sem_verificacoes(novo_simbolo2);                                                                                                   
                                                                                                }
    | FUNCTION VARIAVEL ABRE_PARENTESES tyfields FECHA_PARENTESES DOIS_PONTOS type_id IGUAL exp {                                                                                                     
                                                                                                    $$.node = inicializa_node($4.node, $7.node, $9.node, constroi_codigo_intermediario_fundec1()); 
                                                                                                    
                                                                                                    
                                                                                                    printf("------------- Node da funcao -------------\n");
                                                                                                    simbolo* simbolo_encontrado = busca_simbolo_pelo_nome($2);
                                                                                                    simbolo_encontrado->numero_de_parametros = ($4.node)->numero_de_parametros;
                                                                                                    simbolo_encontrado->label = labelAtual;   
                                                                                                    labelAtual++;
                                                                                                      
                                                                                                    char t[10];
                                                                                                    sprintf(t,"%d",simbolo_encontrado->label);                                                                                                    
                                                                                                    char* temp = get_copia_string(codigo_intermediario_funcao);
                                                                                                    char* temp2 = get_copia_string(monta_codigo_intermediario_da_arvore($9.node));                                                                                                    
                                                                                                    codigo_intermediario_funcao = (char*)malloc(strlen(temp)+strlen(temp2)+strlen("\n\n")
                                                                                                                                                +strlen("L:\n")+strlen(t)+strlen("MOVE(TEMP rv,)"));

                                                                                                    strcat(codigo_intermediario_funcao, temp);
                                                                                                    strcat(codigo_intermediario_funcao, "\n\nL");
                                                                                                    strcat(codigo_intermediario_funcao, t);
                                                                                                    strcat(codigo_intermediario_funcao, ":");
                                                                                                    strcat(codigo_intermediario_funcao, "\n");
                                                                                                    strcat(codigo_intermediario_funcao, "MOVE(TEMP rv,");
                                                                                                    strcat(codigo_intermediario_funcao, temp2);
                                                                                                    strcat(codigo_intermediario_funcao, ")");
                                                                                                    
                                                                                                    atualiza_classe_e_esc_simbolos_n_posicoes_a_frente(simbolo_encontrado, simbolo_encontrado->numero_de_parametros, "parameter");
                                                                                                    
                                                                                                    simbolo* simbolo_da_exp;
                                                                                                    char* tipo_da_exp;
                                                                                                    if(($9.node)->nome){
                                                                                                        printf("------------- exp da funcao tem um nome (é uma variável ou parametro ou tipo) -------------\n");
                                                                                                        simbolo_da_exp = busca_simbolo_por_classe_e_nome_e_bloco(($9.node)->nome, CLASSE_PARAMETRO, $2);

                                                                                                        if(!simbolo_da_exp){
                                                                                                            simbolo_da_exp = busca_simbolo_por_classe_e_nome(($9.node)->nome, CLASSE_VARIAVEL);
                                                                                                        }
                                                                                                    }

                                                                                                    if(simbolo_da_exp){
                                                                                                        tipo_da_exp = simbolo_da_exp->tipo; // SEG FAULT AQUI
                                                                                                    }
                                                                                                    else
                                                                                                        tipo_da_exp = ($9.node)->tipo;

                                                                                                    atualiza_simbolo(simbolo_encontrado, compara_e_define_um_tipo(($7.node)->valor, tipo_da_exp), CLASSE_FUNCAO);                                                                                                                              
                                                                                                    
                                                                                                    if(!procura_parametros_da_funcao_na_arvore(simbolo_encontrado, $9.node)){
                                                                                                        printf("\n==================================================================\n\n");                                                                                                        
                                                                                                        printf("**** Erro: funcao %s, chama simbolos invalidos! ****\n", $2);                                                                                                   
                                                                                                        escreveErro();
                                                                                                    }

                                                                                                    printf("fundec -> function id ( tyfields ) : type-id = exp\n");  
                                                                                                    // struct simbolo* novo_simbolo2 = inicializa_simbolo("end", "?", "?", "?", "?", "?");
                                                                                                    // adiciona_simbolo_sem_verificacoes(novo_simbolo2);     
                                                                                                }
    ;

/**/
decs: 
      dec decs          {   
                            // if(($2.node)->node_filho2)
                            //     if(($2.node)->dec == -1){
                            //         $$.node = inicializa_node($1.node, $2.node, NULL, constroi_codigo_intermediario_decs1());
                            //     }
                            if(($1.node)->dec)
                                $$.node = inicializa_node($1.node, $2.node, NULL, constroi_codigo_intermediario_decs1_vazio()); 
                            else
                                $$.node = inicializa_node($1.node, $2.node, NULL, constroi_codigo_intermediario_decs1()); 
                            printf("decs -> dec decs\n"); 
                        }
    |                   { 
                            $$.node = inicializa_node(NULL, NULL, NULL, constroi_codigo_intermediario_decs2());
                            $$.node->dec = -1;
                            printf("decs -> \n"); 
                        } /* Nenhum código intermediário neste nó */
    ;

/**/
dec: 
      tydec         { 
                        $$.node = inicializa_node($1.node, NULL, NULL, constroi_codigo_intermediario_dec_tydec());
                        $$.node->dec = 1;
                        printf("dec -> tydec\n"); 
                    }
    | vardec        { 
                        $$.node = inicializa_node($1.node, NULL, NULL, constroi_codigo_intermediario_dec_vardec());                                                           
                        $$.node->dec = 0;
                        printf("dec -> vardec\n"); 
                    }
    | fundec        {                             
                        $$.node = inicializa_node($1.node, NULL, NULL, constroi_codigo_intermediario_dec_fundec());                                                        
                        $$.node->dec = 1;                        
                                                                
                        printf("dec -> fundec\n"); 
                    }
    ;

%%

void printCode(char* filename){
    int line = 1;
    printf("\n==================================================================\n");           

    FILE *code = fopen(filename, "r" );
    size_t len= 100;
    char *linha = malloc(len);

    while (getline(&linha, &len, code) > 0){
        printf("%d: %s", line, linha);
        line++;
    }

    printf("\n==================================================================\n\n");
    fclose(code);
}

void escreveErro(){
    // if(erroEncontrado){
        printf("\nNome do arquivo: %s\n",arquivo);
        printf("Linha: %d\n",linhaAtual);
        // printf("Caractere: %d\n",caractere);
        printf("\nANALISE SEMANTICA: ERRO!\n");
        printf("\n==================================================================\n");
        exit(1);
    // }
}

int main(int argc, char** argv) {
    inicializa_tabela_simbolos();
    arquivo = argv[1];
    printCode(argv[1]);

    yyin = fopen(argv[1], "r" );
    
    printf("Listagem da Sintaxe Abstrata:\n\n");
    if (!yyparse()){
        printf("\n\nANALISE SINTATICA: OK!\n");
        printf("\n==================================================================\n\n");
    }

    printf("Listagem do Codigo Intermediario:\n\n");
    imprime_tabela_rotulos();
    printf("ANALISE SEMANTICA: OK!\n");

    codigo_intermediario_final = monta_codigo_intermediario_da_arvore(raiz_da_arvore);   

    printf("\nnull:\n%s\n", codigo_intermediario_final);
    printf("%s\n", codigo_intermediario_funcao);
    printf("\n==================================================================\n\n");
    
    printf("TABELA DE SIMBOLOS:\n\n");    
    imprime_tabela_simbolos();
    printf("\n");  


    return 0;
}

void yyerror(const char* msg) {
    printf("\n\nANALISE SINTATICA: ERRO!\n");
    printf("\n==================================================================\n\n");
    exit(1);
}