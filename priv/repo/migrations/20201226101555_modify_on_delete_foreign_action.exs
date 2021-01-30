defmodule Erflow.Repo.Migrations.ModifyOnDeleteForeignAction do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE tasks DROP CONSTRAINT tasks_job_id_fkey"
    alter table(:tasks) do
      modify :job_id, references(:jobs, on_delete: :delete_all, column: :job_id, type: :binary_id)
    end
  end
end
