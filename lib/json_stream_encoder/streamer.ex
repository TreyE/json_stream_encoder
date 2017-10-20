defmodule JsonStreamEncoder.Streamer do
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
