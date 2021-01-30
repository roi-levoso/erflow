defmodule ErflowWeb.RelationshipView do
  use ErflowWeb, :view
  alias ErflowWeb.RelationshipView

  def render("index.json", %{relationships: relationships}) do
    %{data: render_many(relationships, RelationshipView, "relationship.json")}
  end

  def render("show.json", %{relationship: relationship}) do
    %{data: render_one(relationship, RelationshipView, "relationship.json")}
  end

  def render("relationship.json", %{relationship: relationship}) do
    %{id: relationship.id}
  end
end
