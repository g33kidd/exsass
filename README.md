# Sass

Currently the Makefile is not working. If it were, I'm sure this would work fine.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add exsass to your list of dependencies in `mix.exs`:

        def deps do
          [{:exsass, "~> 0.0.1"}]
        end

  2. Ensure exsass is started before your application:

        def application do
          [applications: [:exsass]]
        end
