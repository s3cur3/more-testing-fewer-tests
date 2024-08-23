defmodule RelativeDatetimeTest1 do
  @moduledoc "A naive set of tests for relative_datetime/2"
  use ExUnit.Case

  describe "relative_datetime/2" do
    test "produces 'just now' for times less than 30 seconds ago" do
      now = DateTime.utc_now()
      assert Timestamps.relative_datetime(now, now) == "just now"
      assert Timestamps.relative_datetime(seconds_ago(29, now), now) == "just now"
    end

    test "produces '1 min ago' for times less than 90 seconds ago" do
      now = DateTime.utc_now()
      assert Timestamps.relative_datetime(seconds_ago(30, now), now) == "1 min ago"
      assert Timestamps.relative_datetime(seconds_ago(89, now), now) == "1 min ago"
    end

    test "produces '2 mins ago' for times less than 2.5 minutes ago" do
      now = DateTime.utc_now()
      assert Timestamps.relative_datetime(seconds_ago(90, now), now) == "2 mins ago"
      assert Timestamps.relative_datetime(seconds_ago(149, now), now) == "2 mins ago"
    end

    # etc.
  end

  defp seconds_ago(seconds, now) do
    DateTime.add(now, -seconds)
  end
end
