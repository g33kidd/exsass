MIX = mix
CFLAGS_SASS=-g -fPIC -O3 -Wall
ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
ERLANG_FLAGS=-I$(ERLANG_PATH)
CFLAGS += -I$(ERLANG_PATH)
LIBSASS_PATH = libsass_src/
CFLAGS += $(CFLAGS_SASS)
CFLAGS += -I$(LIBSASS_PATH)include/

CC?=clang
SASS_SRC = libsass_src/src

SASS_OBJS =\
	$(SASS_SRC)/ast.o \
	$(SASS_SRC)/base64vlq.o \
	$(SASS_SRC)/bind.o \
	$(SASS_SRC)/cencode.o \
	$(SASS_SRC)/color_maps.o \
	$(SASS_SRC)/constants.o \
	$(SASS_SRC)/context.o \
	$(SASS_SRC)/cssize.o \
	$(SASS_SRC)/emitter.o \
	$(SASS_SRC)/environment.o \
	$(SASS_SRC)/error_handling.o \
	$(SASS_SRC)/eval.o \
	$(SASS_SRC)/expand.o \
	$(SASS_SRC)/extend.o \
	$(SASS_SRC)/file.o \
	$(SASS_SRC)/functions.o \
	$(SASS_SRC)/inspect.o \
	$(SASS_SRC)/json.o \
	$(SASS_SRC)/lexer.o \
	$(SASS_SRC)/listize.o \
	$(SASS_SRC)/memory_manager.o \
	$(SASS_SRC)/node.o \
	$(SASS_SRC)/output.o \
	$(SASS_SRC)/parser.o \
	$(SASS_SRC)/plugins.o \
	$(SASS_SRC)/position.o \
	$(SASS_SRC)/prelexer.o \
	$(SASS_SRC)/remove_placeholders.o \
	$(SASS_SRC)/sass_context.o \
	$(SASS_SRC)/sass_functions.o \
	$(SASS_SRC)/sass_interface.o \
	$(SASS_SRC)/sass_util.o \
	$(SASS_SRC)/sass_values.o \
	$(SASS_SRC)/sass.o \
	$(SASS_SRC)/sass2scss.o \
	$(SASS_SRC)/source_map.o \
	$(SASS_SRC)/to_c.o \
	$(SASS_SRC)/to_string.o \
	$(SASS_SRC)/to_value.o \
	$(SASS_SRC)/units.o \
	$(SASS_SRC)/utf8_string.o \
	$(SASS_SRC)/util.o \
	$(SASS_SRC)/values.o

SASS_LIB = libsass_src/lib/libsass.a

NIF_SRC =\
	src/sass_nif.c

ifeq ($(shell uname),Darwin)
	OPTIONS=-dynamiclib -undefined dynamic_lookup
endif

all: sass

sass:
	$(MIX) compile

$(SASS_LIB):
	git submodule update --init && \
	cd libsass_src && \
	git submodule update --init && \
	CFLAGS="-j5" $(MAKE) 2>&1 >/dev/null

priv/sass.so: ${SASfS_LIB} ${NIF_SRC}
	$(CC) $(CFLAGS) -shared $(OPTIONS) \
	$(SASS_OBJS) \
	$(NIF_SRC) \
	-o $@ -lstdc++ 2>&1 >/dev/null

clean:
	rm -rf priv/sass.*
