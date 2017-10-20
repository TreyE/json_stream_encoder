defmodule JsonStreamEncoder do
  @moduledoc """
  Primary API for encoding streaming JSON documents.
  """

  @type io_stream :: IO.device()
  @opaque streamer :: %JsonStreamEncoder.CompactStreamer{} | %JsonStreamEncoder.IndentedStreamer{}
  @type key :: atom | binary | number | nonempty_charlist | boolean

  @spec ary(streamer, (streamer -> streamer)) :: streamer
  def ary(streamer, fn_ary) do
    fn_ary.(streamer |> ary_start) |> ary_end
  end

  @spec ary_start(streamer) :: streamer
  def ary_start(streamer) do
    streamer.__struct__.ary_start(streamer)
  end

  @spec ary_end(streamer) :: streamer
  def ary_end(streamer) do
    streamer.__struct__.ary_end(streamer)
  end

  @spec obj(streamer, (streamer -> streamer)) :: streamer
  def obj(streamer, fn_obj) do
    fn_obj.(streamer |> obj_start) |> obj_end
  end

  @spec obj_start(streamer) :: streamer
  def obj_start(streamer) do
    streamer.__struct__.obj_start(streamer)
  end

  @spec obj_end(streamer) :: streamer
  def obj_end(streamer) do
    streamer.__struct__.obj_end(streamer)
  end

  @spec key(streamer, key) :: streamer
  def key(streamer, k) do
    streamer.__struct__.key(streamer, k)
  end

  @spec val(streamer, any) :: streamer
  def val(streamer, v) do
    streamer.__struct__.val(streamer, v)
  end

  @spec kv(streamer, key, any) :: streamer
  def kv(streamer, k, v) do
    streamer |> key(k) |> val(v)
  end
end
