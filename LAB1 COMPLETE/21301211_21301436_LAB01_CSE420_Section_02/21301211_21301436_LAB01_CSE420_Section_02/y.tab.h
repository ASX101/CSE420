/* A Bison parser, made by GNU Bison 2.7.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2012 Free Software Foundation, Inc.
   
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

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     IF = 258,
     ELSE = 259,
     WHILE = 260,
     ADDOP = 261,
     COMMA = 262,
     FOR = 263,
     DO = 264,
     INT = 265,
     FLOAT = 266,
     VOID = 267,
     SWITCH = 268,
     DEFAULT = 269,
     GOTO = 270,
     BREAK = 271,
     CHAR = 272,
     DOUBLE = 273,
     RETURN = 274,
     CASE = 275,
     CONTINUE = 276,
     PRINTLN = 277,
     MULOP = 278,
     INCOP = 279,
     RELOP = 280,
     ASSIGNOP = 281,
     LOGICOP = 282,
     NOT = 283,
     LPAREN = 284,
     RPAREN = 285,
     LCURL = 286,
     RCURL = 287,
     LTHIRD = 288,
     RTHIRD = 289,
     COLON = 290,
     SEMICOLON = 291,
     ID = 292,
     CONST_INT = 293,
     CONST_FLOAT = 294,
     DECOP = 295
   };
#endif
/* Tokens.  */
#define IF 258
#define ELSE 259
#define WHILE 260
#define ADDOP 261
#define COMMA 262
#define FOR 263
#define DO 264
#define INT 265
#define FLOAT 266
#define VOID 267
#define SWITCH 268
#define DEFAULT 269
#define GOTO 270
#define BREAK 271
#define CHAR 272
#define DOUBLE 273
#define RETURN 274
#define CASE 275
#define CONTINUE 276
#define PRINTLN 277
#define MULOP 278
#define INCOP 279
#define RELOP 280
#define ASSIGNOP 281
#define LOGICOP 282
#define NOT 283
#define LPAREN 284
#define RPAREN 285
#define LCURL 286
#define RCURL 287
#define LTHIRD 288
#define RTHIRD 289
#define COLON 290
#define SEMICOLON 291
#define ID 292
#define CONST_INT 293
#define CONST_FLOAT 294
#define DECOP 295



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
