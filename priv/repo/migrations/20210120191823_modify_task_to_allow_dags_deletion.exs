defmodule Erflow.Repo.Migrations.ModifyTaskToAllowDagsDeletion do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE tasks DROP CONSTRAINT tasks_dag_id_fkey"
    execute "ALTER TABLE jobs DROP CONSTRAINT jobs_dag_id_fkey"

    alter table(:tasks) do
      modify :dag_id, references(:dags,  on_delete: :delete_all, column: :dag_id, type: :binary_id)
    end
    alter table(:jobs) do
      modify :dag_id, references(:dags,  on_delete: :delete_all, column: :dag_id, type: :binary_id)
    end
  end
end
