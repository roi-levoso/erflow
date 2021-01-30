defmodule Erflow.Repo.Migrations.RelationJobsDag do
  use Ecto.Migration

  def change do
    drop table(:dags)
    create table(:dags, primary_key: false) do
      add :dag_id, :binary_id, primary_key: true
      add :schedule, :string
      add :enabled, :boolean
      add :name, :string
      add :owner, :string
      timestamps()
    end
    alter table(:jobs) do
      add :dag_id, references(:dags, column: :dag_id, type: :binary_id)
    end
  end
end
