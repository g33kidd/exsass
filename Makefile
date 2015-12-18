MIX = mix
CFLAGS = -g -fPIC -O3 -Wall

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)

LIBSASS_PATH = deps/libsass
LIBSASS_STATIC = $(LIBSASS_PATH)/lib/libsass.a
CFLAGS += -I$(LIBSASS_PATH)/include/

NIF_SRC = src/sass_nif.c

ifeq ($(shell uname),Darwin)
	OPTIONS += -dynamiclib -undefined dynamic_lookup
endif

all: sass

sass:
	$(MIX) compile

priv/sass.so:
	$(MAKE) -C $(LIBSASS_PATH) -j5 && \
	$(CC) $(CFLAGS) -shared $(OPTIONS) -o $@ $(NIF_SRC) $(LIBSASS_STATIC)

clean:
	rm -rf priv/sass.*

.PHONY: all sass clean
