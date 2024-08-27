defmodule RelativeDatetimeTest3 do
  @moduledoc "A property-based test of relative_datetime/2"
  use ExUnit.Case
  use ExUnitProperties

  property "relative_datetime/2 gives reasonable approximations" do
    check all({secs, mins, hours, days, months, years} <- generate_time_offset()) do
      duration =
        Duration.new!(
          year: -years,
          day: round(-365 / 12 * months) - days,
          hour: -hours,
          minute: -mins,
          second: -secs
        )

      now = DateTime.utc_now()
      then = DateTime.shift(now, duration)

      timeout = DateTime.diff(now, then, :millisecond)

      expected_result =
        cond do
          timeout < :timer.seconds(30) -> "just now"
          timeout < :timer.minutes(1) -> "1 min ago"
          timeout < :timer.minutes(59) -> "#{mins + round(secs / 60)} mins ago"
          timeout < :timer.hours(1) + :timer.minutes(30) -> "1 hour ago"
          timeout <= :timer.hours(23) -> "#{hours + round(mins / 60)} hours ago"
          timeout < :timer.hours(24 + 12) -> "1 day ago"
          timeout <= days_timeout(29) -> "#{days + round(hours / 24)} days ago"
          timeout <= days_timeout(365 / 12 * 1.5) -> "1 month ago"
          timeout <= days_timeout(11 / 12 * 365) -> "#{months + round(days / 30)} months ago"
          timeout <= days_timeout(365 * 1.5) -> "1 year ago"
          true -> "#{years + round(months / 12 + days / 365)} years ago"
        end

      assert Timestamps.relative_datetime(then, now) == expected_result
    end
  end

  defp generate_time_offset do
    StreamData.tuple({
      StreamData.integer(0..59),
      StreamData.integer(0..59),
      StreamData.integer(0..23),
      StreamData.integer(0..29),
      StreamData.integer(0..11),
      StreamData.integer(0..2)
    })
  end

  defp days_timeout(days) do
    :timer.hours(round(days * 24))
  end
end
