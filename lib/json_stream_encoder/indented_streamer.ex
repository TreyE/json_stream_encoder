defmodule JsonStreamEncoder.IndentedStreamer do
  defstruct [:io, state: nil, stack: [], depth: 0]

  use Poison.Encode

  def new(io_stream) do
    %__MODULE__{io: io_stream}
  end

  def ary(state, ary_fun) do
    ary_fun.(state |> ary_start) |> ary_end
  end

  def obj(state, obj_fun) do
    obj_fun.(state |> obj_start) |> obj_end
  end

  def kv(state, k, v) do
    state |> key(k) |> val(v)
  end

  def ary_start(%__MODULE__{io: io_stream, state: nil} = state) do
    IO.binwrite(io_stream, "[")
    %__MODULE__{state | state: {:in_ary, true}, stack: [], depth: 1}
  end

  def ary_start(%__MODULE__{io: io_stream, state: s, stack: stack, depth: d} = state) do
    IO.binwrite(io_stream, "[")
    %__MODULE__{state | state: {:in_ary, true}, stack: [s|stack], depth: d + 1}
  end

  def ary_end(%__MODULE__{io: io_stream, state: {:in_ary, true}, stack: []} = state) do
    IO.binwrite(io_stream, "]")
    %__MODULE__{state | state: nil, stack: [], depth: 0}
  end

  def ary_end(%__MODULE__{io: io_stream, state: {:in_ary, _}, stack: []} = state) do
    IO.binwrite(io_stream, "\n]")
    %__MODULE__{state | state: nil, stack: [], depth: 0}
  end

  def ary_end(%__MODULE__{io: io_stream, state: {:in_ary, true}, stack: [:await_val,new_state|rest],depth: d} = state) do
    IO.binwrite(io_stream, "]")
    %__MODULE__{state | state: new_state, stack: rest, depth: d - 1}
  end

  def ary_end(%__MODULE__{io: io_stream, state: {:in_ary, true}, stack: [new_state|rest], depth: d} = state) do
    IO.binwrite(io_stream, "]")
    %__MODULE__{state | state: new_state, stack: rest, depth: d - 1}
  end

  def ary_end(%__MODULE__{io: io_stream, state: {:in_ary, _}, stack: [:await_val,new_state|rest], depth: d} = state) do
    IO.binwrite(io_stream, ["\n", String.duplicate("  ", d - 1), "]"])
    %__MODULE__{state | state: new_state, stack: rest, depth: d - 1}
  end

  def ary_end(%__MODULE__{io: io_stream, state: {:in_ary, _}, stack: [new_state|rest]} = state, depth: d) do
    IO.binwrite(io_stream, ["\n", String.duplicate("  ", d - 1), "]"])
    %__MODULE__{state | state: new_state, stack: rest, depth: d - 1}
  end

  def obj_start(%__MODULE__{io: io_stream, state: nil} = state) do
    IO.binwrite(io_stream, "{")
    %__MODULE__{state | state: {:in_obj, true}, stack: [], depth: 1}
  end

  def obj_start(%__MODULE__{io: io_stream, state: {:in_ary, true}, stack: stack, depth: d} = state) do
    IO.binwrite(io_stream, ["\n", String.duplicate("  ", d), "{"])
    %__MODULE__{state | state: {:in_obj, true}, stack: [{:in_ary, false}|stack], depth: d + 1}
  end

  def obj_start(%__MODULE__{io: io_stream, state: {:in_ary, _}, stack: stack, depth: d} = state) do
    IO.binwrite(io_stream, [",\n", String.duplicate("  ", d + 1), "{"])
    %__MODULE__{state | state: {:in_obj, true}, stack: [{:in_ary, false}|stack], depth: d + 1}
  end

  def obj_start(%__MODULE__{io: io_stream, state: s, stack: stack, depth: d} = state) do
    IO.binwrite(io_stream, "{")
    %__MODULE__{state | state: {:in_obj, true}, stack: [s|stack], depth: d + 1}
  end

  def obj_end(%__MODULE__{io: io_stream, state: {:in_obj, true}, stack: []} = state) do
    IO.binwrite(io_stream, "}")
    %__MODULE__{state | state: nil, stack: [], depth: 0}
  end

  def obj_end(%__MODULE__{io: io_stream, state: {:in_obj, _}, stack: []} = state) do
    IO.binwrite(io_stream, "\n}")
    %__MODULE__{state | state: nil, stack: [], depth: 0}
  end

  def obj_end(%__MODULE__{io: io_stream, state: {:in_obj, true}, stack: [:await_val,new_state|rest], depth: d} = state) do
    IO.binwrite(io_stream, "}")
    %__MODULE__{state | state: new_state, stack: rest, depth: d - 1}
  end

  def obj_end(%__MODULE__{io: io_stream, state: {:in_obj, true}, stack: [new_state|rest], depth: d} = state) do
    IO.binwrite(io_stream, "}")
    %__MODULE__{state | state: new_state, stack: rest, depth: d - 1}
  end

  def obj_end(%__MODULE__{io: io_stream, state: {:in_obj, _}, stack: [:await_val,new_state|rest], depth: d} = state) do
    IO.binwrite(io_stream, ["\n", String.duplicate("  ", d - 1), "}"])
    %__MODULE__{state | state: new_state, stack: rest, depth: (d - 1)}
  end


  def obj_end(%__MODULE__{io: io_stream, state: {:in_obj, _}, stack: [new_state|rest], depth: d} = state) do
    IO.binwrite(io_stream, ["\n", String.duplicate("  ", d - 1), "}"])
    %__MODULE__{state | state: new_state, stack: rest, depth: (d - 1)}
  end

  def key(%__MODULE__{io: io_stream, state: {:in_obj, true}, stack: stack, depth: d} = state, k) do
    IO.binwrite(io_stream, ["\n", String.duplicate("  ", d), "\"", encode_name(k), "\": "])
    %__MODULE__{state | state: :await_val, stack: [{:in_obj, false}|stack]}
  end

  def key(%__MODULE__{io: io_stream, state: {:in_obj, false}, stack: stack, depth: d} = state, k) do
    IO.binwrite(io_stream, [",\n", String.duplicate("  ", d), "\"", encode_name(k), "\": "])
    %__MODULE__{state | state: :await_val, stack: [{:in_obj, false}|stack]}
  end

  def val(%__MODULE__{io: io_stream, state: :await_val, stack: [past_state|rest]} = state, v) do
    IO.binwrite(io_stream, [Poison.encode!(v)])
    %__MODULE__{state | state: past_state, stack: rest}
  end

  def val(%__MODULE__{io: io_stream, state: {:in_ary, false}, stack: stack, depth: d} = state, v) do
    IO.binwrite(io_stream, [",\n", String.duplicate("  ", d), Poison.encode!(v)])
    %__MODULE__{state | state: {:in_ary, false}, stack: stack}
  end

  def val(%__MODULE__{io: io_stream, state: {:in_ary, true}, stack: stack, depth: d} = state, v) do
    IO.binwrite(io_stream, ["\n", String.duplicate("  ", d), Poison.encode!(v)])
    %__MODULE__{state | state: {:in_ary, false}, stack: stack}
  end

  def val(%__MODULE__{io: io_stream, state: nil} = state, v) do
    IO.binwrite(io_stream, Poison.encode(v))
    state
  end
end
