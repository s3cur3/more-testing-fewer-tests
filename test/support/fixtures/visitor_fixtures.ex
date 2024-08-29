defmodule VisitorFixtures do
  def visitor(opts \\ []) do
    permissions = Access.get(opts, :permissions, :anonymous)

    %{
      user:
        if permissions != :anonymous do
          UserFixtures.user(opts)
        end,
      permissions: permissions
    }
  end
end
