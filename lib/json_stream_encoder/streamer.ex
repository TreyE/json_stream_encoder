defmodule JsonStreamEncoder.Streamer do
  @moduledoc """
    Behaviour which must be implemented for any compliant streamer implementation.
    Used transparently by the `JsonStreamEncoder` module.

    This is mostly internal implementation detail, and shouldn't matter to users.
  """

  @opaque streamer :: struct
  @type io_stream :: IO.device 
  @type key :: atom | binary | number | nonempty_charlist | boolean

  @callback ary_start(streamer) :: streamer
  @callback ary_end(streamer) :: streamer
  @callback obj_start(streamer) :: streamer
  @callback obj_end(streamer) :: streamer
  @callback key(streamer, key) :: streamer
  @callback val(streamer, any) :: streamer
end
