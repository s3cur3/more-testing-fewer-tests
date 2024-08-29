defmodule PermissionsTest6 do
  @moduledoc "Uses parameterized_test instead of built-in parameterization"
  use ExUnit.Case, async: true
  import ParameterizedTest, only: [param_test: 4]

  # Same setup as PermissionsTest5
  setup %{
          permissions: permissions,
          published?: published?,
          post_creator?: post_creator?
        } = context do
    visitor = VisitorFixtures.visitor(context)

    post_author =
      if permissions == :anonymous or not post_creator? do
        UserFixtures.user(permissions: :author)
      else
        visitor
      end

    %{
      visitor: visitor,
      post: Posts.create!(post_author, %{published: published?})
    }
  end

  param_test "permissions match user role",
             """
             | permissions  | published? | post_creator? | can_view? | can_edit? |
             |--------------|------------|---------------|-----------|-----------|
             | :anonymous   | true       | false         | true      | false     |
             | :anonymous   | false      | false         | false     | false     |
             | :viewer      | true       | false         | true      | false     |
             | :viewer      | true       | true          | true      | false     |
             | :viewer      | false      | false         | true      | false     |
             | :viewer      | false      | true          | true      | false     |
             | :author      | true       | false         | true      | true      |
             | :author      | true       | true          | true      | true      |
             | :author      | false      | false         | true      | false     |
             | :author      | false      | true          | true      | true      |
             | :editor      | true       | false         | true      | true      |
             | :editor      | true       | true          | true      | true      |
             | :editor      | false      | false         | true      | true      |
             | :editor      | false      | true          | true      | true      |
             """,
             %{
               visitor: visitor,
               post: post,
               can_view?: can_view?,
               can_edit?: can_edit?
             } do
    assert Permissions.can_view?(visitor, post) == can_view?
    assert Permissions.can_edit?(visitor, post) == can_edit?
  end
end
