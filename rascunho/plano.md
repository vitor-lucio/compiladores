# Plano

## Estruturas a serem criadas

- **Arvore** para montar as partes do código relevantes para a análise semântica, geração do código intermediário e análise de erros.
    - O nó da árvore conterá os seguintes dados:
        - Código intermediário correspondente (String): Conterá a string do código intermediário correspondente. Colocando valores para serem substituidos (exemplo: call(NomeDeUmaFuncao, $parametro1, $parametro2)) pelo código intermediário que esta em outro nó da árvore.
        - Node_filho1 (Node): Nó filho do nó atual
        - Node_filho2 (Node): Nó filho do nó atual
        - Node_filho3 (Node): Nó filho do nó atual 
- **Tabela de simbolos** para guardar nome de variáveis e de tipo. 
    - Guardando nome de variáveis, podemos identificar variaveis usadas sem estarem declaradas e guardar o tipo delas para verificar se, por exemplo, estão sendo usadas nos parâmetros corretos de uma função.
    - Guardando nome de tipos podemos identificar se o tipo usado, em qualquer parte do código, é válido (se não for inteiro ou string, que são tipos já reconhecidos nas linguagem)
- **String para guardar o código intermediário**

## Montando os tipos de comandos

- Primeiro teremos a estrutura inicial do código intermediário do comando no nó deste, que será o ponto inicial da montagem.
- Para preencher os parâmetros (caso tenha), serão feitas chamadas de montagem para o tipo de comando correspondente aos nós do nivel debaixo do comando inicial. Por exemplo: "comando_inicial(%comando1)".replace("%comando1", montar_comando(nó_filho1));
    - Como a montagem consistirá em fazer chamadas para os nós debaixo (caso precise), ela que irá percorrer a arvore de um dado nó até a folha da arvore, pois cada montagem fará chamadas para outras montagens, explorando os nós filhos até chegar em uma folha.
- Caso, na montagem, não tenha nenhum parâmetro, ela irá retornar a string do código intermediário resultado.
- Caso, na montagem, os parâmetros sejam preenchidos pelas outras montagens, ela também irá retornar a string do código intermediário resultado.

## Fluxo de execução

- Montar a árvore
- Montar o código intermediário

## O que foi interpretado mas a documentação não explicita

- Podemos fazer call para qualquer label, sendo função ou não, pois não existe essa distinção no assembly.
- Quando call é executado, ele vai para o label e, após o label executar, ele volta para o label anterior e executa o próximo comando.
- O nome dos operadores aritméticos ou lógicos (no código intermediário) é de nossa escolha, só precisamos mostrar quais usamos.

## Partes que ainda faltam modelar

- Como lidar com nested functions/loops/ifs.

## Casos de erros que ainda faltam tratar

- comando break na "main" do código intermediário.
## Dúvidas

- Como escrever string no código intermediário?
- Como calcular endereços de memoria para os desvios?
- Um label qualquer corresponde, tambem, a um endereço de memoria? senão, o que corresponde a um endereço de memória, tem como dar exemplos?
- (null + 1) corresponde ao endereço de memoria do primeiro comando a ser executado no código intermediário?

## Referências

- [Tutorial de como fazer um compilador de c usando lex e yacc](https://medium.com/codex/building-a-c-compiler-using-lex-and-yacc-446262056aaa)