import Config

if Mix.env() == :test do
  config :stream_data,
    max_runs:
      System.get_env("PROPTEST_MAX_RUNS", "100")
      |> String.to_integer(),
    max_run_time:
      System.get_env("PROPTEST_MAX_RUNTIME_MS", "1000")
      |> String.to_integer()
end
