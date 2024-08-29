defmodule PermissionsTest2 do
  @moduledoc "Tests all permissions for each role in one place"
  use ExUnit.Case, async: true

  setup %{permissions: _} = context do
    %{
      visitor: VisitorFixtures.visitor(context),
      author: UserFixtures.user(permissions: :author)
    }
  end

  @tag permissions: :anonymous
  test "anonymous visitors have the right permissions",
       %{visitor: anonymous_visitor, author: author} do
    {:ok, published_post} = Posts.create(author, %{published: true})
    {:ok, draft_post} = Posts.create(author, %{published: false})

    assert Permissions.can_view?(anonymous_visitor, published_post)
    assert Permissions.can_view?(anonymous_visitor, draft_post)
    refute Permissions.can_edit?(anonymous_visitor, published_post)
    refute Permissions.can_edit?(anonymous_visitor, draft_post)
  end

  @tag permissions: :viewer
  test "logged in viewers have the right permissions",
       %{visitor: viewer, author: author} do
    {:ok, published_post} = Posts.create(author, %{published: true})
    {:ok, draft_post} = Posts.create(author, %{published: false})

    assert Permissions.can_view?(viewer, published_post)
    assert Permissions.can_view?(viewer, draft_post)
    refute Permissions.can_create_post?(viewer)
    refute Permissions.can_edit?(viewer, published_post)
  end

  @tag permissions: :author
  test "authors have the right permissions",
       %{visitor: author, author: other_author} do
    {:ok, others_published_post} = Posts.create(other_author, %{published: true})
    {:ok, others_draft_post} = Posts.create(other_author, %{published: false})
    {:ok, own_post} = Posts.create(author, %{published: false})

    assert Permissions.can_view?(author, others_published_post)
    assert Permissions.can_view?(author, others_draft_post)
    assert Permissions.can_create_post?(author)
    assert Permissions.can_edit?(author, own_post)
    refute Permissions.can_edit?(author, others_published_post)
    refute Permissions.can_edit?(author, others_draft_post)
  end

  @tag permissions: :editor
  test "editors have the right permissions",
       %{visitor: editor, author: author} do
    {:ok, others_published_post} = Posts.create(author, %{published: true})
    {:ok, others_draft_post} = Posts.create(author, %{published: false})
    {:ok, own_post} = Posts.create(editor, %{published: false})

    assert Permissions.can_view?(editor, others_published_post)
    assert Permissions.can_view?(editor, others_draft_post)
    assert Permissions.can_create_post?(editor)
    assert Permissions.can_edit?(editor, own_post)
    assert Permissions.can_edit?(editor, others_published_post)
    assert Permissions.can_edit?(editor, others_draft_post)
  end
end
