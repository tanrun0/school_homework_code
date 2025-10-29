CC = g++
CFLAGS = -g -Wall -Wno-write-strings -Wno-unused-function
FLEX = flex

all: lexer

lexer: cool-lex.cc
	$(CC) $(CFLAGS) cool-lex.cc -o lexer

cool-lex.cc: cool.flex
	$(FLEX) -ocool-lex.cc cool.flex

clean:
	rm -f lexer cool-lex.cc

test: lexer
	@echo "=== 测试基础功能 ==="
	./lexer test_basic.cl
	@echo ""
	@echo "=== 测试字符串处理 ==="
	./lexer test_string.cl
	@echo ""
	@echo "=== 测试错误处理 ==="
	./lexer test_error.cl
	@echo ""
	@echo "=== 测试集成程序 ==="
	./lexer hello.cl

.PHONY: all clean test