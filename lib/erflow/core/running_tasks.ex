defmodule Erflow.Core.RunningTask do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:runningtask_id, :binary_id, autogenerate: true}

  schema "running_tasks" do

    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    field :status, :string
    belongs_to :job, Erflow.Core.Job, references: :job_id, type: :binary_id, foreign_key: :job_id
    belongs_to :task, Erflow.Core.Task, references: :task_id, type: :binary_id, foreign_key: :task_id
  end

  @doc false
  def changeset(running_task, attrs) do
    running_task
    |> cast(attrs, [:job_id, :task_id, :status])
    |> validate_required([:job_id, :task_id])
    |> foreign_key_constraint(:task_id)
    |> foreign_key_constraint(:job_id)
    |> unique_constraint(:unique_task_per_job, name: :unique_task_per_job)
  end

end
