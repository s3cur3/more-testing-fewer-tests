defmodule SnapshotTest do
  use ExUnit.Case, async: true
  import AssertValue

  test "slogan is correct" do
    assert_value Blog.slogan()
  end
end
