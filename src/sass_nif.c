#include <string.h>
#include <unistd.h>
#include <limits.h>
#include "sass/context.h"
#include "erl_nif.h"

static ERL_NIF_TERM sass_compile_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  ErlNifBinary input_binary;
  ErlNifBinary output_binary;

  if (argc != 1) {
    return enif_make_badarg(env);
  }

  if(!enif_inspect_binary(env, argv[0], &input_binary)){
    return enif_make_badarg(env);
  }

  // Create the context and set it's options
  struct sass_data_context* data_ctx = sass_make_data_context((char *) input_binary.data);
  // Create the compiler and compile.
  struct Sass_Compiler* compiler = sass_make_data_compiler(data_ctx);
  sass_compiler_parse(compiler);
  sass_compiler_execute(compiler);

  char *compiled_sass = sass_context_get_output_string(data_ctx);
  if(!enif_alloc_binary(sizeof(compiled_sass), &output_binary))
    return enif_make_badarg(env);

  sass_delete_compiler(compiler);
  sass_delete_data_context(data_ctx);

  return enif_make_binary(env, &output_binary);
}

static int on_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info) {
  return 0;
}

static ErlNifFunc nif_funcs[] = {
  { "compile", 1, sass_compile_nif },
};

ERL_NIF_INIT(Elixir.Sass.Compiler, nif_funcs, NULL, NULL, NULL, NULL);
