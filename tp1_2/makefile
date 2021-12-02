compile:
	flex scanner.l
	yacc -v -d sintaxe.y
	cc y.tab.c

clean:
	rm y.tab.c
	rm y.tab.h
	rm lex.yy.c
	rm a.out
	rm y.output
