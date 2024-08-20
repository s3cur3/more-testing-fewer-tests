defmodule UserFixtures do
  def user(opts \\ []) do
    id = System.unique_integer([:monotonic, :positive])

    %{
      id: id,
      email: "sample-user-#{id}@example.com",
      permissions: Access.get(opts, :permissions, :viewer)
    }
  end
end
