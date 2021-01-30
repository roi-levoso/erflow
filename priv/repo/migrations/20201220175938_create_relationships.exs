defmodule Erflow.Repo.Migrations.CreateRelationships do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :parent, :binary_id
      add :child, :binary_id
      remove :priority
    end

    create table(:relationships) do
      add :parent, references(:tasks, on_delete: :nothing, column: :task_id, type: :binary_id)
      add :child, references(:tasks, on_delete: :nothing, column: :task_id, type: :binary_id)

      timestamps()
    end


    create index(:relationships, [:parent])
    create index(:relationships, [:child])
  end
end
