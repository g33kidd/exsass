MIX = mix
CFLAGS = -g -O3 -Wall
ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)
LIBSASS_PATH = libsass_src/
CFLAGS += -I$(LIBASSS_PATH)/src

ifeq ($(shell uname),Darwin)
	OPTIONS=-dynamiclib -undefined dynamic_lookup
endif

all: sass

sass:
	$(MIX) compile

priv/libsass.so: src/sass_nif.c
	$(MAKE) -C $(LIBSASS_PATH) libsass.a
	$(CC) $(CFLAGS) -shared $(OPTIONS) -o $@ 2>&1 >/dev/null
