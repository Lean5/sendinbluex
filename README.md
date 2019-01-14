# SendInBlue for Elixir

An Elixir library for working with [SendInBlue](https://sendinblue.com).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sendinbluex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sendinbluex, "~> 0.1.0"}
  ]
end
```

## Configuration

To make API calls, it is necessary to configure your SendInBlue API key.

```ex
use Mix.Config

config :sendinbluex, api_key: "YOUR-API-KEY"
```

The Tracker API uses a different key that has to be configured separately:
```ex
config :sendinbluex, tracking_id: "abc123456789"
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sendinbluex](https://hexdocs.pm/sendinbluex).

