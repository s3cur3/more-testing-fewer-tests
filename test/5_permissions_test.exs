defmodule PermissionsTest5 do
  @moduledoc "Demonstrates Elixir 1.18 parameterized tests"
  use ExUnit.Case,
    async: true,
    parameterize:
      for(
        permissions <- [:anonymous_viewer, :viewer, :author, :editor],
        published? <- [true, false],
        post_creator? <- [true, false],
        do: %{
          permissions: permissions,
          published?: published?,
          post_creator?: post_creator?
        }
      )

  # Expands to:
  # parameterize: [
  #   %{user_type: :anonymous, published?: true,  post_creator?: true},
  #   %{user_type: :anonymous, published?: true,  post_creator?: false},
  #   %{user_type: :anonymous, published?: false, post_creator?: true},
  #   %{user_type: :anonymous, published?: false, post_creator?: false},
  #   %{user_type: :viewer,    published?: true,  post_creator?: true},
  #   %{user_type: :viewer,    published?: true,  post_creator?: true},
  #   %{user_type: :viewer,    published?: true,  post_creator?: false},
  #   %{user_type: :viewer,    published?: false, post_creator?: true},
  #   %{user_type: :viewer,    published?: false, post_creator?: false},
  #   ...
  # ]

  setup %{permissions: permissions, published?: published?, post_creator?: post_creator?} =
          context do
    viewer = ViewerFixtures.viewer(context)
    other_author = UserFixtures.user(permissions: :author)

    post_author =
      if permissions == :anonymous_viewer or not post_creator? do
        other_author
      else
        viewer
      end

    %{
      viewer: viewer,
      other_author: other_author,
      post: Posts.create!(post_author, %{published: published?})
    }
  end

  test "user permissions match their role", %{
    user_type: user_type,
    published?: published?,
    post_creator?: post_creator?,
    viewer: viewer,
    post: post
  } do
    can_view? =
      published? or
        user_type == :editor or
        (user_type == :author and post_creator?)

    assert Permissions.can_view?(viewer, post) == can_view?

    can_edit? = ...
    assert Permissions.can_edit?(viewer, post) == can_edit?
  end
end
