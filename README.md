# JsonStreamEncoder

JsonStreamEncoder is a streaming encoder for streaming JSON to an IOish thing in Elixir.

Its use case is for when you care more about constant memory consumption and
parallelism than you do about raw speed.

It is based on and uses [Poison](https://github.com/devinus/poison).

If you don't need a streaming interface and want more protocol support, use Poison. 

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `json_stream_encoder` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:json_stream_encoder, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/json_stream_encoder](https://hexdocs.pm/json_stream_encoder).

