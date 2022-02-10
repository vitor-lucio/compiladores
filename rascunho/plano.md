# Plano

## Estruturas a serem criadas

- **Arvore** para montar as partes do código relevantes para a análise semântica, geração do código intermediário e análise de erros.
    - O nó da árvore conterá os seguintes dados:
        - Código intermediário correspondente (char*): Conterá a string do código intermediário correspondente. Colocando valores para serem substituidos (exemplo: call(NomeDeUmaFuncao, $parametro1, $parametro2)) pelo código intermediário que esta em outro nó da árvore.
        - Node_filho1 (Node): Nó filho do nó atual
        - Node_filho2 (Node): Nó filho do nó atual
        - Node_filho3 (Node): Nó filho do nó atual
        - tipo_codigo_intermediario (char*): tipo de codigo intermediário do nó (statement ou expression, por enquanto, para que possamos definir o comando assembly para "let in end") 
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
- Todo código Tiger semânticamente válido começa com um "let in end"? Pois na documentação tem a seguinte frase na seção 2, primeiro paragrafo, "TIGER é composta de duas seções, uma seção de declarações e uma seção de variáveis e expressões."
- Para as funções nativas do Tiger, como devemos proceder com o código intermediário, sendo que a gente não vai ter o código dessas funções para escrever no código intermediário? A gente só escreve o comando de CALL() e não cria o label?
- Quando um comando do código intermediário não tem um dos parametros, por exemplo quando "SEQ(, BINOP(MAIS, CONST(1), CONST(2)))" seria o código intermediário de "let in 1 + 2 end". Devemos preencher o primeiro parametro de SEQ com "EXP(CONST(0))" como feito no exemplo 1 da documentação da linguagem TIGER?
- Tem recursão de função no TIGER? (uma função dentro da outra, função recursiva...)
- Registros recursivos: type list = {first: int, rest: list}

## Referências

- [Tutorial de como fazer um compilador de c usando lex e yacc](https://medium.com/codex/building-a-c-compiler-using-lex-and-yacc-446262056aaa)

## Rascunho

- ~~Colocar classe para os tipos~~
- ~~Fazer verificação de tipo considerando apenas tipos~~
- ~~Validar e implementar declaracao de variavel e tipos com mesmo nome~~
- ~~Testar casos onde existe uma variavel com o mesmo nome que um tipo~~
- ~~Verificar se o tipo de uma declaracao de array é, de fato, um array e lançar erro~~
- ~~Declaração de tipos com array: var table : rec_arr3 := 3 (salvar que rec_arr3 é um array no node e comparar com o exp)~~
- ~~Criar variável global com o valor da classe e percorrer a tabela até a ultima posição (se a variavel for func ou record)~~
- ~~Colocar classe de tudo que e colocado na tabela de simbolos~~
- ~~Adicionar parametro na tabela mesmo se ja tiver um parametro com o mesmo nome em outra funcao~~
- ~~Terminar declaração de função~~
- ~~Implementar casos de declaração de registros e funções distintos com atributos com mesmo nome~~
- ~~Verificar se no corpo da função existe variavel só dos parametros ou global~~
- ~~Verificaçao de tipo de expressões (comparar com parâmetros ou globais. Ver arvore.c)~~
- Terminar geração do código intermediário de declarações tirando funções
- Terminar geração do código intermediário da declaração de função
- Declaração de variáveis dentro de funções

- Testar casos com várias declarações diferentes juntas, afim de validar se toda parte de validação esta funcionando
- Testar casos de registro com variaveis com mesmo nome que o próprio registro
- Testar e implementar declaracao de parametros, tipos e variaveis com mesmo nome

- Verificação de tipos na chamada de função
- Verificar operacoes aritmeticas com numero + array (está passando sem erros, não deveria)
- Tratar somas entre strings, registros etc (só pode somar se for int)
- A produção de "type_id: VARIAVEL" busca simbolo apenas pelo nome, e as expressões usam o tipo desse simbolo para comparação de tipos, ou seja, a comparação de tipos das expressões não considera a classe da variável (foi necessario resolver isso na produção de função com tipo de retorno definido. Mas a solução foi feita apenas la, pois nao seria exatamente igual para outros casos)

- Declaracao registro: ESEQ(SEQ(MOVE(TEMP t5,CALL(NAME initarray,CONST 0,CONST 2,"TODO")),EXP(CONST 0)),EXP(CONST 0))
- Se em uma SEQ o parametro 2 for vazio, tirar o EXP(CONST 0) e fundir o parametro 1 dessa SEQ na SEQ anterior