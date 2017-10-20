defmodule JsonStreamEncoder.CompactStreamerTest do
  use ExUnit.Case
  doctest JsonStreamEncoder.CompactStreamer

  import JsonStreamEncoder

  defp write_json(work_fn) do
    {:ok, ram_file} = :file.open("", [:read, :write, :binary, :ram])
    work_fn.(ram_file)
    {:ok, pos} = :file.position(ram_file, :cur)
    {:ok, _} = :file.position(ram_file, :bof)
    {:ok, written_data} = :file.read(ram_file, pos + 1)
    :file.close(ram_file)
    written_data
  end

  test "encode an object" do
    written_data = write_json(fn(ram_file) ->
    state = JsonStreamEncoder.CompactStreamer.new(ram_file)
    obj(state, fn(st) -> 
      st |> kv("my_key", 5)
    end)
    end)
    assert("{\"my_key\": 5}" = written_data)
  end

  test "encode an array" do
    written_data = write_json(fn(ram_file) ->
    state = JsonStreamEncoder.CompactStreamer.new(ram_file)
    ary(state, fn(st) -> 
      st |> val("my_val") |> val(2.0003)
    end)
    end)
    assert("[\"my_val\",2.0003]" = written_data)
  end

  test "encode an object in an array" do
    written_data = write_json(fn(ram_file) ->
    state = JsonStreamEncoder.CompactStreamer.new(ram_file)
    ary(state, fn(st) -> 
      obj(st, fn(os) ->
        os |> kv("my_key", 5) |> key("my_key_2") |> val(2.0003)
      end)
    end)
    end)
    assert("[{\"my_key\": 5,\"my_key_2\": 2.0003}]" = written_data)
  end

  test "encode an array in an object" do
    written_data = write_json(fn(ram_file) ->
    state = JsonStreamEncoder.CompactStreamer.new(ram_file)
    obj(state, fn(st) ->
      st |> key("my_key") |> ary(fn(ar) -> ar end)
    end)
    end)
    assert("{\"my_key\": []}" = written_data)
  end

  test "encode an object in an object" do
    written_data = write_json(fn(ram_file) ->
    state = JsonStreamEncoder.CompactStreamer.new(ram_file)
    obj(state, fn(st) ->
      st |> key("my_key") |> obj(fn(ar) -> ar end)
    end)
    end)
    assert("{\"my_key\": {}}" = written_data)
  end

  test "encode an object in an object with an array" do
    written_data = write_json(fn(ram_file) ->
    state = JsonStreamEncoder.CompactStreamer.new(ram_file)
    obj(state, fn(st) ->
      st |> key("my_key") |> obj(fn(ar) -> 
        ar |> key(5) |> ary(fn(mas) -> mas end)
      end)
    end)
    end)
    assert("{\"my_key\": {\"5\": []}}" = written_data)
  end
end
