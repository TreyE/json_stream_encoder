defmodule JsonStreamEncoder.IndentedStreamerTest do
  use ExUnit.Case
  doctest JsonStreamEncoder.IndentedStreamer

  import JsonStreamEncoder.IndentedStreamer

  test "encode an object" do
    {:ok, ram_file} = :file.open("", [:read, :write, :binary, :ram])
    state = JsonStreamEncoder.IndentedStreamer.new(ram_file)
    obj(state, fn(st) -> 
      st |> kv("my_key", 5)
    end)
    {:ok, pos} = :file.position(ram_file, :cur)
    {:ok, start} = :file.position(ram_file, :bof)
    {:ok, written_data} = :file.read(ram_file, pos + 1)
    :file.close(ram_file)
    assert("{\n  \"my_key\": 5\n}" = written_data)
  end

  test "encode an array" do
    {:ok, ram_file} = :file.open("", [:read, :write, :binary, :ram])
    state = JsonStreamEncoder.IndentedStreamer.new(ram_file)
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
    state = JsonStreamEncoder.IndentedStreamer.new(ram_file)
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

  test "encode an array in an object" do
    {:ok, ram_file} = :file.open("", [:read, :write, :binary, :ram])
    state = JsonStreamEncoder.IndentedStreamer.new(ram_file)
    obj(state, fn(st) ->
      st |> key("my_key") |> ary(fn(ar) -> ar end)
    end)
    {:ok, pos} = :file.position(ram_file, :cur)
    {:ok, start} = :file.position(ram_file, :bof)
    {:ok, written_data} = :file.read(ram_file, pos)
    :file.close(ram_file)
    assert("{\n  \"my_key\": []\n}" = written_data)
  end

  test "encode an object in an object" do
    {:ok, ram_file} = :file.open("", [:read, :write, :binary, :ram])
    state = JsonStreamEncoder.IndentedStreamer.new(ram_file)
    obj(state, fn(st) ->
      st |> key("my_key") |> obj(fn(ar) -> ar end)
    end)
    {:ok, pos} = :file.position(ram_file, :cur)
    {:ok, start} = :file.position(ram_file, :bof)
    {:ok, written_data} = :file.read(ram_file, pos)
    :file.close(ram_file)
    assert("{\n  \"my_key\": {}\n}" = written_data)
  end

  test "encode an object in an object with an array" do
    {:ok, ram_file} = :file.open("", [:read, :write, :binary, :ram])
    state = JsonStreamEncoder.IndentedStreamer.new(ram_file)
    obj(state, fn(st) ->
      st |> key("my_key") |> obj(fn(ar) -> 
        ar |> key(5) |> ary(fn(mas) -> mas end)
      end)
    end)
    {:ok, pos} = :file.position(ram_file, :cur)
    {:ok, start} = :file.position(ram_file, :bof)
    {:ok, written_data} = :file.read(ram_file, pos)
    :file.close(ram_file)
    assert("{\n  \"my_key\": {\n    \"5\": []\n  }\n}" = written_data)
  end
end
