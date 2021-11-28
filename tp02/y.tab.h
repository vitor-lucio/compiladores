/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    NUMERO = 258,
    STRING_CONSTANTE = 259,
    NIL = 260,
    BREAK = 261,
    LET = 262,
    IN = 263,
    END = 264,
    FUNCTION = 265,
    TYPE = 266,
    VAR = 267,
    ARRAY = 268,
    DOIS_PONTOS = 269,
    VIRGULA = 270,
    PONTO_E_VIRGULA = 271,
    PONTO = 272,
    ABRE_CHAVES = 273,
    FECHA_CHAVES = 274,
    ABRE_COLCHETE = 275,
    FECHA_COLCHETE = 276,
    ABRE_PARENTESES = 277,
    FECHA_PARENTESES = 278,
    WHILE = 279,
    IF = 280,
    FOR = 281,
    TO = 282,
    ATRIBUICAO = 283,
    VARIAVEL = 284,
    THEN = 285,
    ELSE = 286,
    DO = 287,
    OF = 288,
    OR = 289,
    AND = 290,
    MAIOR_QUE = 291,
    MENOR_QUE = 292,
    IGUAL = 293,
    DIFERENTE = 294,
    MAIOR_IGUAL = 295,
    MENOR_IGUAL = 296,
    MAIS = 297,
    MENOS = 298,
    MULTIPLICACAO = 299,
    DIVISAO = 300
  };
#endif
/* Tokens.  */
#define NUMERO 258
#define STRING_CONSTANTE 259
#define NIL 260
#define BREAK 261
#define LET 262
#define IN 263
#define END 264
#define FUNCTION 265
#define TYPE 266
#define VAR 267
#define ARRAY 268
#define DOIS_PONTOS 269
#define VIRGULA 270
#define PONTO_E_VIRGULA 271
#define PONTO 272
#define ABRE_CHAVES 273
#define FECHA_CHAVES 274
#define ABRE_COLCHETE 275
#define FECHA_COLCHETE 276
#define ABRE_PARENTESES 277
#define FECHA_PARENTESES 278
#define WHILE 279
#define IF 280
#define FOR 281
#define TO 282
#define ATRIBUICAO 283
#define VARIAVEL 284
#define THEN 285
#define ELSE 286
#define DO 287
#define OF 288
#define OR 289
#define AND 290
#define MAIOR_QUE 291
#define MENOR_QUE 292
#define IGUAL 293
#define DIFERENTE 294
#define MAIOR_IGUAL 295
#define MENOR_IGUAL 296
#define MAIS 297
#define MENOS 298
#define MULTIPLICACAO 299
#define DIVISAO 300

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
