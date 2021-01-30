defmodule Erflow.Repo.Migrations.TaskBelongsToDag do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :dag_id, references(:dags, column: :dag_id, type: :binary_id)
    end
  end
end
