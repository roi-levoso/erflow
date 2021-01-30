defmodule Erflow.Core.Dag do
  use Ecto.Schema
  import Ecto.Changeset
  # TODO Think about dag versioning
  @already_exists "ALREADY_EXISTS"

  @primary_key {:dag_id, :binary_id, autogenerate: true}

  schema "dags" do
    field :name, :string
    field :enabled, :boolean
    field :schedule, :string
    field :owner, :string
    has_many :jobs, Erflow.Core.Job,  foreign_key: :job_id
    has_many :tasks, Erflow.Core.Task,  foreign_key: :task_id

    timestamps()
  end

  @doc false
  def changeset(dag, attrs) do
    dag
    |> cast(attrs, [:name, :enabled, :schedule, :owner])
    |> validate_required([:name])
    |> unique_constraint([:name],
    name: :dags_name_index,
    message: @already_exists)
  end


end
