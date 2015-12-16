#include <stdio.h>
#include "sass/context.h"
#include "erl_nif.h"

// TODO: Add compile_file function
// TODO: add more configuration options

static inline ERL_NIF_TERM make_atom(ErlNifEnv* env, const char* name)
{
  ERL_NIF_TERM ret;
  if(enif_make_existing_atom(env, name, &ret, ERL_NIF_LATIN1)) {
    return ret;
  }
  return enif_make_atom(env, name);
}

static inline ERL_NIF_TERM make_tuple(ErlNifEnv* env, const char* mesg, const char* atom_string)
{
  int output_len = sizeof(char) * strlen(mesg);
  ErlNifBinary output_binary;
  enif_alloc_binary(output_len, &output_binary);
  strncpy((char*)output_binary.data, mesg, output_len);
  ERL_NIF_TERM atom = make_atom(env, atom_string);
  ERL_NIF_TERM str = enif_make_binary(env, &output_binary);
  return enif_make_tuple2(env, atom, str);
}

static ERL_NIF_TERM
compile_sass(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
  ErlNifBinary input;
  ERL_NIF_TERM output;

  if(argc != 1) {
    return enif_make_badarg(env);
  }

  if(!enif_inspect_binary(env, argv[0], &input_binary)) {
    return enif_make_badarg(env);
  }

  // Set the contexts
  struct Sass_Data_Context* data_ctx = sass_make_data_context(input);
  struct Sass_Context* ctx = sass_data_context_get_context(data_ctx);
  struct Sass_Options* ctx_opts = sass_data_context_get_options(ctx);

  // Set the options
  sass_option_set_precision(ctx_opts, 10);
  sass_option_set_output_style(ctx_opts, SASS_STYLE_NESTED);

  // Compiles and returns a Tuple
  // should return {:ok, compiled} or {:error, "error message"}
  sass_compile_data_context(data_ctx);
  if(ctx->error_status) {
    if(ctx->error_message) {
      output = make_tuple(env, ctx->error_message, "error");
    }else{
      output = make_tuple(env, "An error occured; no error message available.", "error");
    }
  }else if(ctx->output_string) {
    output = make_tuple(env, ctx->output_string, "ok");
  }else{
    output = make_tuple(env, "Unknown internal error.", "error");
  }

  sass_delete_data_context(data_ctx);
  return output;
}

static int on_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info){
  return 0;
}

static ErlNifFunc nif_funcs[] = {
  { "compile", 1, compile_sass }
}

ERL_NIF_INIT(Elixir.Sass.Compiler, nif_funcs, NULL, NULL, NULL, NULL);
