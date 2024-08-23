defmodule Timestamps do
  @doc """
  A human-readable description of dates in the past
  """
  @spec relative_datetime(DateTime.t(), DateTime.t()) :: String.t()
  def relative_datetime(timestamp, now \\ DateTime.utc_now()) do
    diff = DateTime.diff(now, timestamp, :second)

    seconds_per_minute = 60
    seconds_per_hour = seconds_per_minute * 60
    seconds_per_day = seconds_per_hour * 24
    seconds_per_month = seconds_per_day * (365 / 12)
    seconds_per_year = seconds_per_day * 365

    cond do
      diff < 30 -> "just now"
      diff < seconds_per_minute -> format(1, "min")
      diff <= seconds_per_hour - seconds_per_minute -> format(diff / seconds_per_minute, "min")
      diff <= seconds_per_day - seconds_per_hour -> format(diff / seconds_per_hour, "hour")
      diff <= seconds_per_month - seconds_per_day -> format(diff / seconds_per_day, "day")
      diff <= seconds_per_month * 11 -> format(diff / seconds_per_month, "month")
      true -> format(diff / seconds_per_year, "year")
    end
  end

  defp format(value, unit) do
    rounded = round(value)

    case rounded do
      1 -> "1 #{unit} ago"
      _ -> "#{rounded} #{unit}s ago"
    end
  end
end
