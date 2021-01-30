defmodule Erflow.Repo.Migrations.AddTimesToRunningTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      remove :start_time
      remove :end_time
    end
    alter table(:running_tasks) do
      add :end_time, :utc_datetime
      add :start_time, :utc_datetime
    end

  end
end
