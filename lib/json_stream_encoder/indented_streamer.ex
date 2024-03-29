defmodule JsonStreamEncoder.IndentedStreamer do
  @moduledoc false

  defstruct [:io, state: nil, stack: [], depth: 0, indent_string: nil]

  @behaviour JsonStreamEncoder.Streamer

  @default_indent "  "

  def new(io_stream, indent_val \\ @default_indent) do
    %__MODULE__{io: io_stream, indent_string: indent_val}
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

  def ary_end(%__MODULE__{io: io_stream, state: {:in_ary, _}, stack: [:await_val,new_state|rest], depth: d, indent_string: id_str} = state) do
    IO.binwrite(io_stream, ["\n", String.duplicate(id_str, d - 1), "]"])
    %__MODULE__{state | state: new_state, stack: rest, depth: d - 1}
  end

  def ary_end(%__MODULE__{io: io_stream, state: {:in_ary, _}, stack: [new_state|rest], indent_string: id_str} = state, depth: d) do
    IO.binwrite(io_stream, ["\n", String.duplicate(id_str, d - 1), "]"])
    %__MODULE__{state | state: new_state, stack: rest, depth: d - 1}
  end

  def obj_start(%__MODULE__{io: io_stream, state: nil} = state) do
    IO.binwrite(io_stream, "{")
    %__MODULE__{state | state: {:in_obj, true}, stack: [], depth: 1}
  end

  def obj_start(%__MODULE__{io: io_stream, state: {:in_ary, true}, stack: stack, depth: d, indent_string: id_str} = state) do
    IO.binwrite(io_stream, ["\n", String.duplicate(id_str, d), "{"])
    %__MODULE__{state | state: {:in_obj, true}, stack: [{:in_ary, false}|stack], depth: d + 1}
  end

  def obj_start(%__MODULE__{io: io_stream, state: {:in_ary, _}, stack: stack, depth: d, indent_string: id_str} = state) do
    IO.binwrite(io_stream, [",\n", String.duplicate(id_str, d), "{"])
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

  def obj_end(%__MODULE__{io: io_stream, state: {:in_obj, _}, stack: [:await_val,new_state|rest], depth: d, indent_string: id_str} = state) do
    IO.binwrite(io_stream, ["\n", String.duplicate(id_str, d - 1), "}"])
    %__MODULE__{state | state: new_state, stack: rest, depth: (d - 1)}
  end


  def obj_end(%__MODULE__{io: io_stream, state: {:in_obj, _}, stack: [new_state|rest], depth: d, indent_string: id_str} = state) do
    IO.binwrite(io_stream, ["\n", String.duplicate(id_str, d - 1), "}"])
    %__MODULE__{state | state: new_state, stack: rest, depth: (d - 1)}
  end

  def key(%__MODULE__{io: io_stream, state: {:in_obj, true}, stack: stack, depth: d, indent_string: id_str} = state, k) do
    IO.binwrite(io_stream, ["\n", String.duplicate(id_str, d), encode_name(k), ": "])
    %__MODULE__{state | state: :await_val, stack: [{:in_obj, false}|stack]}
  end

  def key(%__MODULE__{io: io_stream, state: {:in_obj, false}, stack: stack, depth: d, indent_string: id_str} = state, k) do
    IO.binwrite(io_stream, [",\n", String.duplicate(id_str, d), encode_name(k), ": "])
    %__MODULE__{state | state: :await_val, stack: [{:in_obj, false}|stack]}
  end

  def val(%__MODULE__{io: io_stream, state: :await_val, stack: [past_state|rest]} = state, v) do
    IO.binwrite(io_stream, [Jason.encode_to_iodata!(v)])
    %__MODULE__{state | state: past_state, stack: rest}
  end

  def val(%__MODULE__{io: io_stream, state: {:in_ary, false}, stack: stack, depth: d, indent_string: id_str} = state, v) do
    IO.binwrite(io_stream, [",\n", String.duplicate(id_str, d), Jason.encode_to_iodata!(v)])
    %__MODULE__{state | state: {:in_ary, false}, stack: stack}
  end

  def val(%__MODULE__{io: io_stream, state: {:in_ary, true}, stack: stack, depth: d, indent_string: id_str} = state, v) do
    IO.binwrite(io_stream, ["\n", String.duplicate(id_str, d), Jason.encode_to_iodata!(v)])
    %__MODULE__{state | state: {:in_ary, false}, stack: stack}
  end

  def val(%__MODULE__{io: io_stream, state: nil} = state, v) do
    IO.binwrite(io_stream, Jason.encode_to_iodata!(v))
    state
  end

  defp encode_name(name) when is_binary(name) do
    Jason.encode!(name)
  end

  defp encode_name(name) do
    encoded_key = Jason.encode!(name)
    case String.length(encoded_key) do
      0 -> ""
      _ ->
        case String.at(encoded_key, 0) do
          ?" -> encoded_key
          _ -> Jason.encode!(encoded_key)
        end
    end
  end
end
