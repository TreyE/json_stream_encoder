defmodule JsonStreamEncoder.IndentedStreamerTest do
  use ExUnit.Case
  doctest JsonStreamEncoder.IndentedStreamer

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
      state = JsonStreamEncoder.IndentedStreamer.new(ram_file)
      obj(state, fn(st) -> 
      st |> kv("my_key", 5)
      end)
    end)
    assert("{\n  \"my_key\": 5\n}" = written_data)
  end

  test "encode an array" do
    written_data = write_json(fn(ram_file) ->
      state = JsonStreamEncoder.IndentedStreamer.new(ram_file)
      ary(state, fn(st) -> 
      st |> val("my_val") |> val(2.0003)
      end)
    end)
    assert("[\n  \"my_val\",\n  2.0003\n]" = written_data)
  end

  test "encode an object in an array" do
    written_data = write_json(fn(ram_file) ->
      state = JsonStreamEncoder.IndentedStreamer.new(ram_file)
      ary(state, fn(st) -> 
        obj(st, fn(os) ->
          os |> kv("my_key", 5) |> key("my_key_2") |> val(2.0003)
        end)
      end)
    end)
    assert("[\n  {\n    \"my_key\": 5,\n    \"my_key_2\": 2.0003\n  }\n]" = written_data)
  end

  test "encode an array in an object" do
    written_data = write_json(fn(ram_file) ->
      state = JsonStreamEncoder.IndentedStreamer.new(ram_file)
      obj(state, fn(st) ->
        st |> key("my_key") |> ary(fn(ar) -> ar end)
      end)
    end)
    assert("{\n  \"my_key\": []\n}" = written_data)
  end

  test "encode an object in an object" do
    written_data = write_json(fn(ram_file) ->
      state = JsonStreamEncoder.IndentedStreamer.new(ram_file)
      obj(state, fn(st) ->
        st |> key("my_key") |> obj(fn(ar) -> ar end)
      end)
    end)
    assert("{\n  \"my_key\": {}\n}" = written_data)
  end

  test "encode an object in an object with an array" do
    written_data = write_json(fn(ram_file) ->
      state = JsonStreamEncoder.IndentedStreamer.new(ram_file)
      obj(state, fn(st) ->
        st |> key("my_key") |> obj(fn(ar) -> 
        ar |> key(5) |> ary(fn(mas) -> mas end)
        end)
      end)
    end)
    assert("{\n  \"my_key\": {\n    \"5\": []\n  }\n}" = written_data)
  end

  test "encode an a set of objects in an array" do
    written_data = write_json(fn(ram_file) ->
      state = JsonStreamEncoder.IndentedStreamer.new(ram_file)
      ary(state, fn(st) ->
        st |> obj(fn(o) -> 
         o |> key("key1") |> obj(fn(o2) -> kv(o2, "inside_key", "val") end)
        end) |> obj(fn(o) ->
          o |> kv("key2", 2)
        end)
      end)
    end)
    assert("[\n  {\n    \"key1\": {\n      \"inside_key\": \"val\"\n    }\n  },\n  {\n    \"key2\": 2\n  }\n]" = written_data)
  end
end
