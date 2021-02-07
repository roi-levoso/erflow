defmodule Erflow.Model.Job do
  use Ecto.Schema
  import Ecto.Changeset

  @already_exists "ALREADY_EXISTS"

  @primary_key {:job_id, :binary_id, autogenerate: true}

  schema "jobs" do
    field :end_time, :utc_datetime
    field :scheduled_time, :utc_datetime
    field :start_time, :utc_datetime
    field :status, :string
    has_many :running_tasks, Erflow.Model.RunningTask, on_replace: :delete
    belongs_to :dag, Erflow.Model.Dag, references: :dag_id, type: :binary_id, foreign_key: :dag_id

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:scheduled_time, :dag_id, :status])
    |> validate_required([:scheduled_time, :dag_id, :status])
    |> foreign_key_constraint(:dag_id)
    |> unique_constraint([:scheduled_time],
    name: :jobs_dag_id_scheduled_time_index,
    message: @already_exists)
  end
end
