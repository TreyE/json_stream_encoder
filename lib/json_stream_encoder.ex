defmodule JsonStreamEncoder do
  @moduledoc """
  Documentation for JsonStreamEncoder.
  """

  def ary(streamer, fn_ary) do
    fn_ary.(streamer |> ary_start) |> ary_end
  end

  def ary_start(streamer) do
    streamer.__struct__.ary_start(streamer)
  end

  def ary_end(streamer) do
    streamer.__struct__.ary_end(streamer)
  end

  def obj(streamer, fn_obj) do
    fn_obj.(streamer |> obj_start) |> obj_end
  end

  def obj_start(streamer) do
    streamer.__struct__.obj_start(streamer)
  end

  def obj_end(streamer) do
    streamer.__struct__.obj_end(streamer)
  end

  def key(streamer, k) do
    streamer.__struct__.key(streamer, k)
  end

  def val(streamer, v) do
    streamer.__struct__.val(streamer, v)
  end

  def kv(streamer, k, v) do
    streamer |> key(k) |> val(v)
  end
end
