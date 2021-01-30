defmodule Erflow.Repo.Migrations.CreateIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:dags, [:name])
    create unique_index(:jobs, [:dag_id, :scheduled_time])
  end
end
