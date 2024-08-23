defmodule PermissionsTest5 do
  @moduledoc "Demonstrates Elixir 1.18 parameterized tests"
  use ExUnit.Case,
    async: true,
    parameterize:
      for(
        permissions <- [:anonymous, :viewer, :author, :editor],
        published? <- [true, false],
        post_creator? <- [true, false],
        do: %{
          permissions: permissions,
          published?: published?,
          post_creator?: post_creator?
        }
      )

  @moduletag elixir_1_18_only: true
  # Expands to:
  # parameterize: [
  #   %{permissions: :anonymous, published?: true,  post_creator?: true},
  #   %{permissions: :anonymous, published?: true,  post_creator?: false},
  #   %{permissions: :anonymous, published?: false, post_creator?: true},
  #   %{permissions: :anonymous, published?: false, post_creator?: false},
  #   %{permissions: :viewer,    published?: true,  post_creator?: true},
  #   %{permissions: :viewer,    published?: true,  post_creator?: true},
  #   %{permissions: :viewer,    published?: true,  post_creator?: false},
  #   %{permissions: :viewer,    published?: false, post_creator?: true},
  #   %{permissions: :viewer,    published?: false, post_creator?: false},
  #   ...
  # ]

  setup %{
          permissions: permissions,
          published?: published?,
          post_creator?: post_creator?
        } = context do
    viewer = ViewerFixtures.viewer(context)

    post_author =
      if permissions == :anonymous or not post_creator? do
        UserFixtures.user(permissions: :author)
      else
        viewer
      end

    %{
      viewer: viewer,
      post: Posts.create!(post_author, %{published: published?})
    }
  end

  test "user permissions match their role", %{
    permissions: permissions,
    published?: published?,
    post_creator?: post_creator?,
    viewer: viewer,
    post: post
  } do
    can_view? =
      published? or
        permissions == :editor or
        (permissions == :author and post_creator?)

    assert Permissions.can_view?(viewer, post) == can_view?

    can_edit? =
      permissions == :editor or
        (permissions == :author and post_creator?)

    assert Permissions.can_edit?(viewer, post) == can_edit?
  end
end
