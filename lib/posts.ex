defmodule Posts do
  def create(author, attrs) do
    post =
      %{
        # Support passing in either a user or a viewer and pulling out its user
        author: Map.get(author, :user, author),
        published: Access.get(attrs, :published, false)
      }

    {:ok, post}
  end

  def create!(author, attrs) do
    {:ok, post} = create(author, attrs)
    post
  end
end
