defmodule JsonStreamEncoder do
  @moduledoc """
  Primary API for encoding streaming JSON documents.
  """

  @type io_stream :: IO.device()
  @opaque streamer :: %JsonStreamEncoder.CompactStreamer{} | %JsonStreamEncoder.IndentedStreamer{}
  @type key :: atom | binary | number | nonempty_charlist | boolean
  @type indentation :: boolean | binary
  @type encodeable :: Poison.Encoder.t

  @spec new(io_stream) :: streamer
  @doc """
    Create a new streamer without indentation.
  """
  def new(io_stream) do
    JsonStreamEncoder.CompactStreamer.new(io_stream)
  end

  @spec new(io_stream, indentation) :: streamer
  @doc """
    Create a new streamer with the given indentation settings.

    Pass `false` for no indentation, `true` for default indentation (two spaces), or
    a `binary` representing the desired indentation string.
  """
  def new(io_stream, false) do
    JsonStreamEncoder.CompactStreamer.new(io_stream)
  end

  def new(io_stream, true) do
    JsonStreamEncoder.IndentedStreamer.new(io_stream)
  end

  def new(io_stream, indent_value) do
    JsonStreamEncoder.IndentedStreamer.new(io_stream, indent_value)
  end

@doc """
Encode an array into the stream, using the contents of the function to set elements.

## Examples

    ary(streamer, fn(stream) ->
      stream |> val(1) |> val("2")
    end)
    #=> [1,"2"]

"""
  @spec ary(streamer, (streamer -> streamer)) :: streamer
  def ary(streamer, fn_ary) do
    fn_ary.(streamer |> ary_start) |> ary_end
  end

@doc """
Start encoding an array.  Always pair with `ary_end/1`.

More often you will want to use `ary/2`.

## Examples

    streamer |> ary_start() |> val(1) |> val("2") |> ary_end()
    #=> [1,"2"]

"""
  @spec ary_start(streamer) :: streamer
  def ary_start(streamer) do
    streamer.__struct__.ary_start(streamer)
  end

@doc """
End an array you previously started encoding with `ary_start/1`.
"""
  @spec ary_end(streamer) :: streamer
  def ary_end(streamer) do
    streamer.__struct__.ary_end(streamer)
  end

@doc """
Encode an object into the stream, using the contents of the function to set key/value pairs.

## Examples

    obj(streamer, fn(stream) ->
      stream |> kv(1,"2")
    end)
    #=> {"1": "2"}

"""
  @spec obj(streamer, (streamer -> streamer)) :: streamer
  def obj(streamer, fn_obj) do
    fn_obj.(streamer |> obj_start) |> obj_end
  end

@doc """
Start encoding an object.  Always pair with `obj_end/1`.

More often you will want to use `obj/2`.

## Examples

    streamer |> obj_start() |> kv(1,"2") |> obj_end()
    #=> {"1": "2"}

"""
  @spec obj_start(streamer) :: streamer
  def obj_start(streamer) do
    streamer.__struct__.obj_start(streamer)
  end

@doc """
End an object you previously started encoding with `obj_start/1`.
"""
  @spec obj_end(streamer) :: streamer
  def obj_end(streamer) do
    streamer.__struct__.obj_end(streamer)
  end

@doc """
Encode a key for an object.

Always follow this with a `val/2`, `obj/2`, or `ary/2` - otherwise your JSON won't make any sense.
"""
  @spec key(streamer, key) :: streamer
  def key(streamer, k) do
    streamer.__struct__.key(streamer, k)
  end

  @doc """
    Encode a value.
    
    Usable anywhere you would expect a JSON value:
    - The root of a document
    - After a key
    - As an array element
  """
  @spec val(streamer, encodeable) :: streamer
  def val(streamer, v) do
    streamer.__struct__.val(streamer, v)
  end

  @doc """
    Encode a key-value pair for an object.

    You should really only use this if your value is simple, otherwise use `key/2` in combination with other functions.
  """
  @spec kv(streamer, key, encodeable) :: streamer
  def kv(streamer, k, v) do
    streamer |> key(k) |> val(v)
  end
end
