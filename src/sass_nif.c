#include <string.h>
#include <unistd.h>
#include <limits.h>
#include "sass.h"
#include "erl_nif.h"

static inline ERL_NIF_TERM
make_atom(ErlNifEnv* env, const char* name) {
  ERL_NIF_TERM ret;
  if (enif_make_existing_atom(env, name, &ret, ERL_NIF_LATIN1)) {
    return ret;
  }

  return enif_make_atom(env, name);
}

static inline ERL_NIF_TERM
make_response_tuple(ErlNifEnv* env, const char* atom_string, const char* msg)
{
  ErlNifBinary output_binary;
  int output_len = sizeof(char) * strlen(msg);

  enif_alloc_binary(output_len, &output_binary);
  strncpy((char *) output_binary.data, msg, output_len);

  ERL_NIF_TERM atom = make_atom(env, atom_string);
  ERL_NIF_TERM str = enif_make_binary(env, &output_binary);

  return enif_make_tuple2(env, atom, str);
}

static ERL_NIF_TERM
sass_compile_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  ErlNifBinary input;

  if (argc != 1) {
    return enif_make_badarg(env);
  }

  if (enif_inspect_binary(env, argv[0], &input) == 0) {
    return enif_make_badarg(env);
  }

  if (input.size < 1) {
    return argv[0];
  }

  struct Sass_Data_Context* data_ctx = sass_make_data_context((char *) input.data);
  struct Sass_Compiler* compiler = sass_make_data_compiler(data_ctx);

  // SASS OPTIONS
  // struct Sass_Options* options = sass_data_context_get_options(data_ctx);
  // sass_option_set_precision(options, 1);
  // sass_option_set_source_comments(options, true);

  sass_compiler_parse(compiler);
  sass_compiler_execute(compiler);

  char *compiled_sass = sass_context_get_output_string(data_ctx);

  // sass_delete_compiler(compiler);
  // sass_delete_data_context(data_ctx);

  if (sass_context_get_error_status(data_ctx) != 0) {
    return make_response_tuple(env, "nok", sass_context_get_error_text(data_ctx));
  }

  return make_response_tuple(env, "ok", compiled_sass);
}

static int
on_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info) {
  return 0;
}

static ErlNifFunc nif_funcs[] = {
  { "compile", 1, sass_compile_nif },
};

ERL_NIF_INIT(Elixir.Sass.Compiler, nif_funcs, NULL, NULL, NULL, NULL);
