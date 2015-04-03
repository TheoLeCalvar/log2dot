CC=clang++

ifdef DEBUG
CFLAGS=-g -DDEBUG -Wall
else
CFLAGS=-O3 -Wall -Wno-format
endif
LDFLAGS=-L/usr/local/opt/flex/lib
CFLAGS=-I/usr/local/opt/flex/include

## Directories
DOBJ=obj
DSRC=src

SRCS= parser.lex.cpp parser.cpp

OBJS = $(SRCS:.cpp=.o)

FLEX = flex
FLEXFLAGS =
BISON = /usr/local/Cellar/bison/3.0.4/bin/bison
BISONFLAGS =


all: log2dot

%.o: %.cpp
	$(CC) $(CFLAGS) -c $^

log2dot: $(OBJS)
	$(CC) $^ $(CFLAGS) $(LDFLAGS) -lfl -o log2dot

clean:
	rm -f *.o
	rm -f log2dot

distclean: clean
	rm -f parser.lex.hpp parser.lex.cpp
	rm -f parser.hpp parser.cpp

%.lex.hpp %.lex.cpp: %.l
	$(FLEX) --header-file=$*.lex.hpp -o$*.lex.cpp $(FLEXFLAGS) $<

%.hpp %.cpp: %.y
	$(BISON) --defines=$*.hpp -o$*.cpp $(BISONFLAGS) $<


parser.lex.cpp: parser.hpp
parser.cpp: parser.lex.hpp
