defmodule RelativeDatetimeTest2 do
  @moduledoc "A param_test set for relative_datetime/2"
  use ExUnit.Case
  import ParameterizedTest

  setup %{
    secs: secs,
    mins: mins,
    hours: hours,
    days: days,
    months: months,
    years: years
  } do
    duration =
      Duration.new!(
        year: years,
        month: months,
        day: days,
        hour: hours,
        minute: mins,
        second: secs
      )

    now = DateTime.utc_now()
    future = DateTime.shift(now, duration)
    duration_seconds = DateTime.diff(future, now, :second)

    %{total_secs: duration_seconds}
  end

  param_test "relative_datetime/2 gives reasonable interpretations",
             """
             | secs | mins | hours | days | months | years | expected      |
             |------|------|-------|------|--------|-------|---------------|
             | 0    | 0    | 0     | 0    | 0      | 0     | "just now"    |
             | 29   | 0    | 0     | 0    | 0      | 0     | "just now"    |
             | 30   | 0    | 0     | 0    | 0      | 0     | "1 min ago"   |
             | 0    | 1    | 0     | 0    | 0      | 0     | "1 min ago"   |
             | 29   | 1    | 0     | 0    | 0      | 0     | "1 min ago"   |
             | 29   | 2    | 0     | 0    | 0      | 0     | "2 mins ago"  |
             | 0    | 59   | 0     | 0    | 0      | 0     | "59 mins ago" |
             | 1    | 59   | 0     | 0    | 0      | 0     | "1 hour ago"  |
             | 0    | 29   | 1     | 0    | 0      | 0     | "1 hour ago"  |
             | 0    | 31   | 1     | 0    | 0      | 0     | "2 hours ago" |
             # etc.
             """,
             %{total_secs: total_secs, expected: expected} do
    now = DateTime.utc_now()
    then = DateTime.add(now, -total_secs)
    assert Timestamps.relative_datetime(then, now) == expected
  end
end
