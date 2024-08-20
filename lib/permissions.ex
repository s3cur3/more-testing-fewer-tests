defmodule Permissions do
  def can_view?(viewer, post) do
    post.published or viewer.permissions in [:viewer, :author, :editor]
  end

  def can_edit?(viewer, post) do
    cond do
      viewer.permissions == :author and post.author == viewer.user -> true
      viewer.permissions == :editor -> true
      true -> false
    end
  end

  def can_create_post?(viewer) do
    viewer.permissions in [:author, :editor]
  end
end
