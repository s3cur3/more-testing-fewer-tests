defmodule PermissionsTest1 do
  @moduledoc "A naive way to test all permissions for each role"
  use ExUnit.Case, async: true

  setup %{permissions: _} = context do
    %{
      viewer: ViewerFixtures.viewer(context),
      author: UserFixtures.user(permissions: :author)
    }
  end

  @tag permissions: :anonymous_viewer
  test "anonymous viewers can view a published post",
       %{viewer: anonymous_viewer, author: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    assert Permissions.can_view?(anonymous_viewer, post)
  end

  @tag permissions: :anonymous_viewer
  test "anonymous viewers cannot view a draft post",
       %{viewer: anonymous_viewer, author: author} do
    {:ok, post} = Posts.create(%{published: false}, author)
    refute Permissions.can_view?(anonymous_viewer, post)
  end

  @tag permissions: :anonymous_viewer
  test "anonymous viewers cannot create a post", %{viewer: anonymous_viewer} do
    refute Permissions.can_create_post?(anonymous_viewer)
  end

  @tag permissions: :anonymous_viewer
  test "anonymous viewers cannot edit a post",
       %{viewer: anonymous_viewer, author: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    refute Permissions.can_edit?(anonymous_viewer, post)
  end

  @tag permissions: :viewer
  test "logged in viewers can view a published post",
       %{viewer: viewer, author: author} do
    {:ok, post} = Posts.create(%{published: false}, author)
    assert Permissions.can_view?(viewer, post)
  end

  @tag permissions: :viewer
  test "logged in viewers can view a draft post",
       %{viewer: viewer, author: author} do
    {:ok, post} = Posts.create(%{published: false}, author)
    assert Permissions.can_view?(viewer, post)
  end

  @tag permissions: :viewer
  test "logged in viewers can't create a post",
       %{viewer: viewer} do
    refute Permissions.can_create_post?(viewer)
  end

  @tag permissions: :viewer
  test "logged in viewers can't edit a post they created",
       %{viewer: viewer, author: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    refute Permissions.can_edit?(viewer, post)
  end

  @tag permissions: :viewer
  test "logged in viewers can't edit a post others created",
       %{viewer: viewer, author: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    refute Permissions.can_edit?(viewer, post)
  end

  @tag permissions: :author
  test "authors can view a published post",
       %{viewer: author, author: other_author} do
    {:ok, post} = Posts.create(other_author, %{published: true})
    assert Permissions.can_view?(author, post)
  end

  @tag permissions: :author
  test "authors can view a draft post",
       %{viewer: author, author: other_author} do
    {:ok, post} = Posts.create(other_author, %{published: false})
    assert Permissions.can_view?(author, post)
  end

  @tag permissions: :author
  test "authors can create a post",
       %{viewer: author} do
    assert Permissions.can_create_post?(author)
  end

  @tag permissions: :author
  test "authors can edit a post they created", %{viewer: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    assert Permissions.can_edit?(author, post)
  end

  @tag permissions: :author
  test "authors can't edit a post others created",
       %{viewer: author, author: other_author} do
    {:ok, post} = Posts.create(other_author, %{published: true})
    refute Permissions.can_edit?(author, post)
  end

  @tag permissions: :editor
  test "editors can view a published post",
       %{viewer: editor, author: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    assert Permissions.can_view?(editor, post)
  end

  @tag permissions: :editor
  test "editors can view a draft post",
       %{viewer: editor, author: author} do
    {:ok, post} = Posts.create(author, %{published: false})
    assert Permissions.can_view?(editor, post)
  end

  @tag permissions: :editor
  test "editors can create a post",
       %{viewer: editor} do
    assert Permissions.can_create_post?(editor)
  end

  @tag permissions: :editor
  test "editors can edit a post they created",
       %{viewer: editor, author: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    assert Permissions.can_edit?(editor, post)
  end

  @tag permissions: :editor
  test "editors can edit a post others created",
       %{viewer: editor, author: other_author} do
    {:ok, post} = Posts.create(other_author, %{published: true})
    assert Permissions.can_edit?(editor, post)
  end
end
