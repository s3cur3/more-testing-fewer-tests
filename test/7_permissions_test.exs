defmodule PermissionsTest7 do
  @moduledoc "Uses parameterized_test with a custom description"
  use ExUnit.Case, async: true
  import ParameterizedTest, only: [param_test: 4]

  # Same setup as PermissionsTest5
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

  param_test "permissions match user role",
             """
             | permissions  | published? | post_creator? | can_view? | can_edit? | description                                  |
             |--------------|------------|---------------|-----------|-----------|----------------------------------------------|
             | :anonymous   | true       | false         | true      | false     | "anonymous viewers can view published posts" |
             | :anonymous   | false      | false         | false     | false     | "anonymous viewers can't view drafts"        |
             | :viewer      | true       | false         | true      | false     | "viewers can view others' published posts"   |
             | :viewer      | true       | true          | true      | false     | "viewers can view their own past posts"      |
             | :viewer      | false      | false         | true      | false     | "viewers can view others' drafts"            |
             | :viewer      | false      | true          | true      | false     | "viewers can view their own past drafts"     |
             | :author      | true       | false         | true      | true      | "authors can view others' published posts"   |
             | :author      | true       | true          | true      | true      | "authors can edit their own posts"           |
             | :author      | false      | false         | true      | false     | "authors can view others' drafts"            |
             | :author      | false      | true          | true      | true      | "authors can edit their own drafts"          |
             | :editor      | true       | false         | true      | true      | "editors can edit others' published posts"   |
             | :editor      | true       | true          | true      | true      | "editors can edit their own posts"           |
             | :editor      | false      | false         | true      | true      | "editors can edit others' drafts"            |
             | :editor      | false      | true          | true      | true      | "editors can edit their own drafts"          |
             """,
             %{
               permissions: permissions,
               published?: published?,
               post_creator?: post_creator?,
               viewer: viewer,
               post: post,
               can_view?: can_view?,
               can_edit?: can_edit?
             } do
    assert Permissions.can_view?(viewer, post) == can_view?
    assert Permissions.can_edit?(viewer, post) == can_edit?
  end
end
