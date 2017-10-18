defmodule JsonStreamEncoderTest do
  use ExUnit.Case
  doctest JsonStreamEncoder

  test "greets the world" do
    assert JsonStreamEncoder.hello() == :world
  end
end
