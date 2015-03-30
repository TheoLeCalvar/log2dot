CC=clang++

LDFLAGS=-L/usr/local/opt/flex/lib
CFLAGS=-I/usr/local/opt/flex/include


all: log2dot

log2dot.tab.c log2dot.tab.h: log2dot.y global.h
	bison -d log2dot.y

lex.yy.c: log2dot.l log2dot.tab.h global.h
	flex log2dot.l

log2dot: lex.yy.c log2dot.tab.c log2dot.tab.h
	$(CC) log2dot.tab.c lex.yy.c $(CFLAGS) $(LDFLAGS) -lfl -o log2dot

clean:
	@rm -f *.tab.*
	@rm -f lex.yy.c
	@rm -f *.o
	@rm -f log2dot
