defmodule Erflow.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :task_id, :binary_id, primary_key: true
      add :start_time, :utc_datetime
      add :end_time, :utc_datetime
      add :status, :string
      add :name, :string

      timestamps()
    end

  end
end
