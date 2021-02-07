defmodule Erflow.Model.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:task_id, :binary_id, autogenerate: true}

  schema "tasks" do

    field :name, :string
    field :mod, :string
    field :fun, :string
    field :args, {:array, :string}
    belongs_to :dag, Erflow.Model.Dag, references: :dag_id, type: :binary_id, foreign_key: :dag_id
    has_many :running_tasks, Erflow.Model.RunningTask, on_replace: :delete
    many_to_many :parent, Erflow.Model.Task, join_through: "tasks_tasks", join_keys: [child_id: :task_id, parent_id: :task_id], on_replace: :delete
    many_to_many :child, Erflow.Model.Task, join_through: "tasks_tasks", join_keys: [parent_id: :task_id, child_id: :task_id], on_replace: :delete
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:dag_id, :name, :mod, :fun, :args])
    |> validate_required([:dag_id, :name])
    |> foreign_key_constraint(:dag_id)
    |> unique_constraint(:unique_task_per_dag, name: :unique_task_per_dag)
  end

end
