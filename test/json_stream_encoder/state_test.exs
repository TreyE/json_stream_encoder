defmodule JsonStreamEncoder.Test do
  use ExUnit.Case
  doctest JsonStreamEncoder.State

  import JsonStreamEncoder.State

  test "encode an object" do
    {:ok, ram_file} = :file.open("", [:read, :write, :binary, :ram])
    state = JsonStreamEncoder.State.new(ram_file)
    obj(state, fn(st) -> 
      st |> kv("my_key", 5)
    end)
    {:ok, pos} = :file.position(ram_file, :cur)
    {:ok, start} = :file.position(ram_file, :bof)
    {:ok, written_data} = :file.read(ram_file, pos + 1)
    IO.puts(written_data)
    :file.close(ram_file)
  end

  test "encode an array" do
    {:ok, ram_file} = :file.open("", [:read, :write, :binary, :ram])
    state = JsonStreamEncoder.State.new(ram_file)
    ary(state, fn(st) -> 
      st |> val("my_val") |> val(2.0003)
    end)
    {:ok, pos} = :file.position(ram_file, :cur)
    {:ok, start} = :file.position(ram_file, :bof)
    {:ok, written_data} = :file.read(ram_file, pos + 1)
    IO.puts(written_data)
    :file.close(ram_file)
  end

  test "encode an object in an array" do
    {:ok, ram_file} = :file.open("", [:read, :write, :binary, :ram])
    state = JsonStreamEncoder.State.new(ram_file)
    ary(state, fn(st) -> 
      obj(st, fn(os) ->
        os |> kv("my_key", 5) |> key("my_key_2") |> val(2.0003)
      end)
    end)
    {:ok, pos} = :file.position(ram_file, :cur)
    {:ok, start} = :file.position(ram_file, :bof)
    {:ok, written_data} = :file.read(ram_file, pos)
    IO.puts(written_data)
    :file.close(ram_file)
  end

end
