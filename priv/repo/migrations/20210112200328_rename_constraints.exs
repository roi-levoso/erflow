defmodule Erflow.Repo.Migrations.RenameConstraints do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE running_tasks RENAME CONSTRAINT jobs_tasks_pkey TO running_tasks_pkey"
    execute "ALTER TABLE running_tasks RENAME CONSTRAINT jobs_tasks_task_fkey TO running_tasks_task_fkey"
    execute "ALTER TABLE running_tasks RENAME CONSTRAINT jobs_tasks_job_fkey TO running_tasks_job_fkey"
  end
end
