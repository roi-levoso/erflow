defmodule Erflow.Repo.Migrations.RenameIndexes do
  use Ecto.Migration

  def change do
    execute "ALTER INDEX jobs_tasks_task_index RENAME  TO running_tasks_task_index"
    execute "ALTER INDEX jobs_tasks_job_index RENAME  TO running_tasks_job_index"

  end
end
