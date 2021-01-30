defmodule Erflow.Repo.Migrations.AddCascadeDeleteToDags do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE tasks DROP CONSTRAINT tasks_dag_id_fkey"
    alter table(:tasks) do
      modify :dag_id, references(:dags, column: :dag_id, type: :binary_id, on_delete: :delete_all)
    end

  end
end
