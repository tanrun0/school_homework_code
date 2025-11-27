# Minimal Makefile for the simplified COOL parser demo
FLEX=flex
BISON=bison
CXX=g++
CXXFLAGS=-std=c++11 -Wall -g

all: parser

parser: parser.tab.c lex.yy.c
	$(CXX) $(CXXFLAGS) parser.tab.c lex.yy.c -lfl -o parser

parser.tab.c parser.tab.h: parser.y
	$(BISON) -d -o parser.tab.c parser.y

lex.yy.c: lexer.l parser.tab.h
	$(FLEX) -o lex.yy.c lexer.l

clean:
	rm -f parser lex.yy.c parser.tab.c parser.tab.h

.PHONY: all clean
