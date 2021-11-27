compile:
	flex scanner.l
	yacc -d sintaxe.y
	cc y.tab.c

run:
	./a.out

clean:
	rm y.tab.c
	rm y.tab.h
	rm lex.yy.c
	rm a.out
