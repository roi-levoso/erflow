defmodule Erflow.Repo.Migrations.CreateDags do
  use Ecto.Migration

  def change do
    create table(:dags, primary_key: false) do
      add :dag_id, :binary_id, primary_key: true
      add :scheduled_time, :utc_datetime
      add :start_time, :utc_datetime
      add :end_time, :utc_datetime
      add :status, :string
      add :enabled, :boolean
      add :name, :string

      timestamps()
    end

  end
end
