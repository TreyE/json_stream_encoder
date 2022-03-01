# JsonStreamEncoder

JsonStreamEncoder is a streaming encoder for streaming JSON to an IOish thing in Elixir.

Its use case is for when you care more about constant memory consumption and
parallelism than you do about raw speed.

It is based on and uses [Jason](https://github.com/michalmuskala/jason).

If you don't need a streaming interface and want more protocol support, use Jason. 

## Installation

Using [Hex](https://hex.pm), the package can be installed by adding `json_stream_encoder` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:json_stream_encoder, "~> 0.2.0"}
  ]
end
```

The docs for the most recent version can be found at [Hex Docs](https://hexdocs.pm/json_stream_encoder).

