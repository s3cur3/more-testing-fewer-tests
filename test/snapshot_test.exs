defmodule SnapshotTest do
  use ExUnit.Case, async: true
  import AssertValue

  test "slogan is correct" do
    assert_value Blog.slogan() == "Hello ElixirConf 2024"
  end
end