defmodule Permissions do
  def can_view?(visitor, post) do
    post.published or visitor.permissions in [:viewer, :author, :editor]
  end

  def can_edit?(visitor, post) do
    cond do
      visitor.permissions == :author and post.author == visitor.user -> true
      visitor.permissions == :editor -> true
      true -> false
    end
  end

  def can_create_post?(visitor) do
    visitor.permissions in [:author, :editor]
  end
end
