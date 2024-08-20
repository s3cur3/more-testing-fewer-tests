defmodule PermissionsTest3 do
  @moduledoc "Removes noise from the tests of all permissions for each role"
  use ExUnit.Case, async: true

  setup %{permissions: _} = context do
    %{
      viewer: ViewerFixtures.viewer(context),
      author: UserFixtures.user(permissions: :author)
    }
  end

  @tag permissions: :anonymous
  test "anonymous viewers have the right permissions",
       %{viewer: anonymous_viewer, author: author} do
    {:ok, published_post} = Posts.create(author, %{published: true})
    {:ok, draft_post} = Posts.create(author, %{published: false})

    for {expected, actual} <-
          [
            {true, Permissions.can_view?(anonymous_viewer, published_post)},
            {false, Permissions.can_view?(anonymous_viewer, draft_post)},
            {false, Permissions.can_edit?(anonymous_viewer, published_post)},
            {false, Permissions.can_edit?(anonymous_viewer, draft_post)}
          ] do
      assert actual == expected
    end
  end

  @tag permissions: :viewer
  test "logged in viewers have the right permissions",
       %{viewer: viewer, author: author} do
    {:ok, published_post} = Posts.create(author, %{published: true})
    {:ok, draft_post} = Posts.create(author, %{published: false})

    for {expected, actual} <-
          [
            {true, Permissions.can_view?(viewer, published_post)},
            {true, Permissions.can_view?(viewer, draft_post)},
            {false, Permissions.can_create_post?(viewer)},
            {false, Permissions.can_edit?(viewer, published_post)}
          ] do
      assert actual == expected
    end
  end

  @tag permissions: :author
  test "authors have the right permissions",
       %{viewer: author, author: other_author} do
    {:ok, others_published_post} = Posts.create(other_author, %{published: true})
    {:ok, others_draft_post} = Posts.create(other_author, %{published: false})
    {:ok, own_post} = Posts.create(author, %{published: false})

    for {expected, actual} <-
          [
            {true, Permissions.can_view?(author, others_published_post)},
            {true, Permissions.can_view?(author, others_draft_post)},
            {true, Permissions.can_create_post?(author)},
            {true, Permissions.can_edit?(author, own_post)},
            {false, Permissions.can_edit?(author, others_published_post)},
            {false, Permissions.can_edit?(author, others_draft_post)}
          ] do
      assert actual == expected
    end
  end

  @tag permissions: :editor
  test "editors have the right permissions",
       %{viewer: editor, author: author} do
    {:ok, others_published_post} = Posts.create(author, %{published: true})
    {:ok, others_draft_post} = Posts.create(author, %{published: false})
    {:ok, own_post} = Posts.create(editor, %{published: false})

    for {expected, actual} <-
          [
            {true, Permissions.can_view?(editor, others_published_post)},
            {true, Permissions.can_view?(editor, others_draft_post)},
            {true, Permissions.can_create_post?(editor)},
            {true, Permissions.can_edit?(editor, own_post)},
            {true, Permissions.can_edit?(editor, others_published_post)},
            {true, Permissions.can_edit?(editor, others_draft_post)}
          ] do
      assert actual == expected
    end
  end
end
