defmodule Blog do
  def slogan do
    "Hello ElixirConf #{Date.utc_today().year}"
  end
end
