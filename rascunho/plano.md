# Plano

## Estruturas a serem criadas

- **Arvore** para montar as partes do código relevantes para a análise semântica, geração do código intermediário e análise de erros.
    - O nó da árvore conterá os seguintes dados:
        - Tipo de comando (String): Indicará qual o tipo de comando desse nó, ou seja, se é um "Let", "Function", "For", "Var". Esse tipo tem o objetivo de permitir que a gente possa tratar cada tipo de comando de forma independente.
        - Código intermediário correspondente (String): Conterá a string do código intermediário correspondente. Colocando valores para serem substituidos (exemplo: call(NomeDeUmaFuncao, %parametro1, %parametro2)) pelo código intermediário que esta em outro nó da árvore.
        - Valor (String): Algum valor que precise ser guardado no nó (Por exemplo um numero, ou uma string, ou o nome de um tipo)
        - Node_filho1 (Node): Nó filho do nó atual
        - Node_filho2 (Node): Nó filho do nó atual
        - Node_filho3 (Node): Nó filho do nó atual 
- **Tabela de simbolos** para guardar nome de variáveis e de tipo. 
    - Guardando nome de variáveis, podemos identificar variaveis usadas sem estarem declaradas e guardar o tipo delas para verificar se, por exemplo, estão sendo usadas nos parâmetros corretos de uma função.
    - Guardando nome de tipos podemos identificar se o tipo usado, em qualquer parte do código, é válido (se não for inteiro ou string, que são tipos já reconhecidos nas linguagem)
- **String para guardar o código intermediário**
- **Numero do próximo comando a ser executado na "main" do código intermediário**

## Montando os tipos de comandos

- Primeiro teremos a estrutura inicial do código intermediário do comando no nó deste, que será o ponto inicial da montagem.
- Para preencher os parâmetros (caso tenha), serão feitas chamadas de montagem para o tipo de comando correspondente aos nós do nivel debaixo do comando inicial. Por exemplo: "comando_inicial(%comando1)".replace("%comando1", montar_comando(nó_filho1));
    - Como a montagem consistirá em fazer chamadas para os nós debaixo (caso precise), ela que irá percorrer a arvore de um dado nó até a folha da arvore, pois cada montagem fará chamadas para outras montagens, explorando os nós filhos até chegar em uma folha.
- Caso, na montagem, não tenha nenhum parâmetro, ela irá retornar a string do código intermediário resultado.
- Caso, na montagem, os parâmetros sejam preenchidos pelas outras montagens, ela também irá retornar a string do código intermediário resultado.

## Insights

- Não vai ser preciso guardar o nome das variaveis, podemos colocar o nome que quisermos. O que importa para o código intermediário é a posição de memória delas.

## Fluxo de execução

- Montar a árvore
- Montar o código intermediário

## Partes que ainda faltam modelar

- Como lidar com nested functions/loops/ifs.

## Dúvidas

- Como escrever string no código intermediário?
- Como calcular endereços para os desvios?
- Mem(null + 1) corresponde ao endereço do primeiro comando a ser executado no código intermediário?
