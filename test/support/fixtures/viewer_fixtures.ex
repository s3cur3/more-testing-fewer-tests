defmodule ViewerFixtures do
  def viewer(opts \\ []) do
    permissions = Access.get(opts, :permissions, :anonymous_viewer)

    %{
      user:
        if permissions != :anonymous_viewer do
          UserFixtures.user(opts)
        end,
      permissions: permissions
    }
  end
end
