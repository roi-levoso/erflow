defmodule Erflow.Repo.Migrations.ModifyIdRunningTasks do
  use Ecto.Migration

  def change do
    alter table(:running_tasks) do
      remove :id
      add :runningtask_id, :binary_id, primary_key: true
    end
  end
end
