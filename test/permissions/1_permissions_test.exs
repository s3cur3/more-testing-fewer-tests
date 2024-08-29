defmodule PermissionsTest1 do
  @moduledoc "A naive way to test all permissions for each role"
  use ExUnit.Case, async: true

  setup %{permissions: _} = context do
    %{
      visitor: VisitorFixtures.visitor(context),
      author: UserFixtures.user(permissions: :author)
    }
  end

  @tag permissions: :anonymous
  test "anonymous visitors can view a published post",
       %{visitor: anonymous_visitor, author: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    assert Permissions.can_view?(anonymous_visitor, post)
  end

  @tag permissions: :anonymous
  test "anonymous visitors cannot view a draft post",
       %{visitor: anonymous_visitor, author: author} do
    {:ok, post} = Posts.create(%{published: false}, author)
    refute Permissions.can_view?(anonymous_visitor, post)
  end

  @tag permissions: :anonymous
  test "anonymous visitors cannot create a post", %{visitor: anonymous_visitor} do
    refute Permissions.can_create_post?(anonymous_visitor)
  end

  @tag permissions: :anonymous
  test "anonymous visitors cannot edit a post",
       %{visitor: anonymous_visitor, author: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    refute Permissions.can_edit?(anonymous_visitor, post)
  end

  @tag permissions: :viewer
  test "logged in viewers can view a published post",
       %{visitor: viewer, author: author} do
    {:ok, post} = Posts.create(%{published: false}, author)
    assert Permissions.can_view?(viewer, post)
  end

  @tag permissions: :viewer
  test "logged in viewers can view a draft post",
       %{visitor: viewer, author: author} do
    {:ok, post} = Posts.create(%{published: false}, author)
    assert Permissions.can_view?(viewer, post)
  end

  @tag permissions: :viewer
  test "logged in viewers can't create a post",
       %{visitor: viewer} do
    refute Permissions.can_create_post?(viewer)
  end

  @tag permissions: :viewer
  test "logged in viewers can't edit a post they created",
       %{visitor: viewer, author: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    refute Permissions.can_edit?(viewer, post)
  end

  @tag permissions: :viewer
  test "logged in viewers can't edit a post others created",
       %{visitor: viewer, author: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    refute Permissions.can_edit?(viewer, post)
  end

  @tag permissions: :author
  test "authors can view a published post",
       %{visitor: author, author: other_author} do
    {:ok, post} = Posts.create(other_author, %{published: true})
    assert Permissions.can_view?(author, post)
  end

  @tag permissions: :author
  test "authors can view a draft post",
       %{visitor: author, author: other_author} do
    {:ok, post} = Posts.create(other_author, %{published: false})
    assert Permissions.can_view?(author, post)
  end

  @tag permissions: :author
  test "authors can create a post",
       %{visitor: author} do
    assert Permissions.can_create_post?(author)
  end

  @tag permissions: :author
  test "authors can edit a post they created", %{visitor: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    assert Permissions.can_edit?(author, post)
  end

  @tag permissions: :author
  test "authors can't edit a post others created",
       %{visitor: author, author: other_author} do
    {:ok, post} = Posts.create(other_author, %{published: true})
    refute Permissions.can_edit?(author, post)
  end

  @tag permissions: :editor
  test "editors can view a published post",
       %{visitor: editor, author: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    assert Permissions.can_view?(editor, post)
  end

  @tag permissions: :editor
  test "editors can view a draft post",
       %{visitor: editor, author: author} do
    {:ok, post} = Posts.create(author, %{published: false})
    assert Permissions.can_view?(editor, post)
  end

  @tag permissions: :editor
  test "editors can create a post",
       %{visitor: editor} do
    assert Permissions.can_create_post?(editor)
  end

  @tag permissions: :editor
  test "editors can edit a post they created",
       %{visitor: editor, author: author} do
    {:ok, post} = Posts.create(author, %{published: true})
    assert Permissions.can_edit?(editor, post)
  end

  @tag permissions: :editor
  test "editors can edit a post others created",
       %{visitor: editor, author: other_author} do
    {:ok, post} = Posts.create(other_author, %{published: true})
    assert Permissions.can_edit?(editor, post)
  end
end
