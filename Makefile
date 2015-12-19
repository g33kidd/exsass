CC = gcc
MIX = mix
CFLAGS = -Wall -O2 -fPIC

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)

LIBSASS_PATH = deps/libsass
LIBSASS_SRC = $(LIBSASS_PATH)/src
LIBSASS_STATIC = $(LIBSASS_PATH)/lib/libsass.a
CFLAGS += -I$(LIBSASS_PATH)/include

NIF_SRC = src/sass_nif.c

ifeq ($(shell uname),Darwin)
	OPTIONS += -dynamiclib -undefined dynamic_lookup
endif

all: sass

sass:
	$(MIX) compile

priv/sass.so: $(NIF_SRC)
	$(MAKE) BUILD="static" -C $(LIBSASS_PATH) && \
	$(CC) $(CFLAGS) $(OPTIONS) -shared -o $@ $(NIF_SRC) $(LIBSASS_STATIC) -lstdc++

clean:
	$(MIX) clean
	#$(MAKE) -C $(LIBSASS_PATH) clean
	rm -rf priv/sass.*

.PHONY: all sass clean
