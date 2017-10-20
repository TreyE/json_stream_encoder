defmodule JsonStreamEncoder.CompactStreamer do
  @moduledoc false

  defstruct [:io, state: nil, stack: []]

  use Poison.Encode

  @behaviour JsonStreamEncoder.Streamer

  def new(io_stream) do
    %__MODULE__{io: io_stream}
  end

  def ary_start(%__MODULE__{io: io_stream, state: nil} = state) do
    IO.binwrite(io_stream, "[")
    %__MODULE__{state | state: {:in_ary, true}, stack: []}
  end

  def ary_start(%__MODULE__{io: io_stream, state: s, stack: stack} = state) do
    IO.binwrite(io_stream, "[")
    %__MODULE__{state | state: {:in_ary, true}, stack: [s|stack]}
  end

  def ary_end(%__MODULE__{io: io_stream, state: {:in_ary, _}, stack: []} = state) do
    IO.binwrite(io_stream, "]")
    %__MODULE__{state | state: nil, stack: []}
  end

  def ary_end(%__MODULE__{io: io_stream, state: {:in_ary, _}, stack: [:await_val,new_state|rest]} = state) do
    IO.binwrite(io_stream, "]")
    %__MODULE__{state | state: new_state, stack: rest}
  end

  def ary_end(%__MODULE__{io: io_stream, state: {:in_ary, _}, stack: [new_state|rest]} = state) do
    IO.binwrite(io_stream, "]")
    %__MODULE__{state | state: new_state, stack: rest}
  end

  def obj_start(%__MODULE__{io: io_stream, state: nil} = state) do
    IO.binwrite(io_stream, "{")
    %__MODULE__{state | state: {:in_obj, true}, stack: []}
  end

  def obj_start(%__MODULE__{io: io_stream, state: {:in_ary, true}, stack: stack} = state) do
    IO.binwrite(io_stream, "{")
    %__MODULE__{state | state: {:in_obj, true}, stack: [{:in_ary, false}|stack]}
  end

  def obj_start(%__MODULE__{io: io_stream, state: {:in_ary, _}, stack: stack} = state) do
    IO.binwrite(io_stream, ",{")
    %__MODULE__{state | state: {:in_obj, true}, stack: [{:in_ary, false}|stack]}
  end

  def obj_start(%__MODULE__{io: io_stream, state: s, stack: stack} = state) do
    IO.binwrite(io_stream, "{")
    %__MODULE__{state | state: {:in_obj, true}, stack: [s|stack]}
  end

  def obj_end(%__MODULE__{io: io_stream, state: {:in_obj, _}, stack: []} = state) do
    IO.binwrite(io_stream, "}")
    %__MODULE__{state | state: nil, stack: []}
  end

  def obj_end(%__MODULE__{io: io_stream, state: {:in_obj, _}, stack: [:await_val,new_state|rest]} = state) do
    IO.binwrite(io_stream, "}")
    %__MODULE__{state | state: new_state, stack: rest}
  end

  def obj_end(%__MODULE__{io: io_stream, state: {:in_obj, _}, stack: [new_state|rest]} = state) do
    IO.binwrite(io_stream, "}")
    %__MODULE__{state | state: new_state, stack: rest}
  end

  def key(%__MODULE__{io: io_stream, state: {:in_obj, true}, stack: stack} = state, k) do
    IO.binwrite(io_stream, ["\"", encode_name(k), "\": "])
    %__MODULE__{state | state: :await_val, stack: [{:in_obj, false}|stack]}
  end

  def key(%__MODULE__{io: io_stream, state: {:in_obj, false}, stack: stack} = state, k) do
    IO.binwrite(io_stream, [",\"", encode_name(k), "\": "])
    %__MODULE__{state | state: :await_val, stack: [{:in_obj, false}|stack]}
  end

  def val(%__MODULE__{io: io_stream, state: :await_val, stack: [past_state|rest]} = state, v) do
    IO.binwrite(io_stream, Poison.encode!(v))
    %__MODULE__{state | state: past_state, stack: rest}
  end

  def val(%__MODULE__{io: io_stream, state: {:in_ary, false}, stack: stack} = state, v) do
    IO.binwrite(io_stream, [",", Poison.encode!(v)])
    %__MODULE__{state | state: {:in_ary, false}, stack: stack}
  end

  def val(%__MODULE__{io: io_stream, state: {:in_ary, true}, stack: stack} = state, v) do
    IO.binwrite(io_stream, Poison.encode!(v))
    %__MODULE__{state | state: {:in_ary, false}, stack: stack}
  end

  def val(%__MODULE__{io: io_stream, state: nil} = state, v) do
    IO.binwrite(io_stream, Poison.encode!(v))
    state
  end
end
