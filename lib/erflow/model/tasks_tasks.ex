defmodule Erflow.Model.TasksTasks do
  use Ecto.Schema
  import Ecto.Changeset


  @primary_key false
  schema "tasks_tasks" do
    belongs_to :parent, Erflow.Model.Task, references: :task_id, type: :binary_id, foreign_key: :parent_id, primary_key: true
    belongs_to :child, Erflow.Model.Task, references: :task_id, type: :binary_id, foreign_key: :child_id, primary_key: true
  end

  @doc false
  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:parent_id, :child_id])
    |> validate_required([:parent_id, :child_id])
    |> foreign_key_constraint(:child_id)
    |> foreign_key_constraint(:parent_id)
    |> unique_constraint(:unique_child_and_parent, name: :unique_child_and_parent)
  end



end
