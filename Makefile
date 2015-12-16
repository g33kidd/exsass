MIX = mix
CFLAGS_SASS=-g -fPIC -O3
ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
ERLANG_FLAGS=-I$(ERLANG_PATH)
CFLAGS += -I$(ERLANG_PATH)
LIBSASS_PATH = libsass_src/
CFLAGS += $(CFLAGS_SASS) -I$(LIBSASS_PATH)/include

ifeq ($(shell uname),Darwin)
	OPTIONS=-dynamiclib -undefined dynamic_lookup
endif

all: sass

sass:
	$(MIX) compile

priv/libsass.so: src/sass_nif.c
	mkdir -p priv && \
	$(CC) $(CFLAGS) $(ERLANG_FLAGS) -shared $(OPTIONS) \
		src/sass_nif.c -o $@ 2>&1 >/dev/null
