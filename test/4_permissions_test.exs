defmodule PermissionsTest4 do
  @moduledoc "Combines all permissions tests in one place"
  use ExUnit.Case, async: true

  test "user permissions match their role" do
    anonymous = ViewerFixtures.viewer(permissions: :anonymous)
    viewer = ViewerFixtures.viewer(permissions: :viewer)
    author = ViewerFixtures.viewer(permissions: :author)
    editor = ViewerFixtures.viewer(permissions: :editor)

    other_author = UserFixtures.user(permissions: :author)
    {:ok, published_post} = Posts.create(other_author, %{published: true})
    {:ok, draft_post} = Posts.create(other_author, %{published: false})

    {:ok, viewers_post} = Posts.create(viewer, %{published: false})
    {:ok, authors_post} = Posts.create(author, %{published: false})
    {:ok, editors_post} = Posts.create(editor, %{published: false})

    for {expected, actual} <-
          [
            # View permissions
            {true, Permissions.can_view?(anonymous, published_post)},
            {true, Permissions.can_view?(viewer, published_post)},
            {true, Permissions.can_view?(author, published_post)},
            {true, Permissions.can_view?(editor, published_post)},

            # Edit others' posts
            {false, Permissions.can_edit?(anonymous, published_post)},
            {false, Permissions.can_edit?(anonymous, draft_post)},
            {false, Permissions.can_edit?(viewer, published_post)},
            {false, Permissions.can_edit?(viewer, draft_post)},
            {false, Permissions.can_edit?(author, published_post)},
            {false, Permissions.can_edit?(author, draft_post)},
            {true, Permissions.can_edit?(editor, published_post)},
            {true, Permissions.can_edit?(editor, draft_post)},

            # Edit own posts
            {false, Permissions.can_edit?(viewer, viewers_post)},
            {false, Permissions.can_edit?(author, authors_post)},
            {false, Permissions.can_edit?(editor, editors_post)},

            # Create permissions
            {false, Permissions.can_create_post?(anonymous)},
            {false, Permissions.can_create_post?(viewer)},
            {true, Permissions.can_create_post?(author)},
            {true, Permissions.can_create_post?(editor)}
          ] do
      assert actual == expected
    end
  end
end
