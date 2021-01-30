defmodule Erflow.Repo.Migrations.AddDagsDefinitionTableChanges do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE jobs RENAME CONSTRAINT dags_pkey TO jobs_pkey"
    create table(:dags) do
      add :dag_id, :binary_id, primary_key: true
      add :schedule, :string
      add :enabled, :boolean
      add :name, :string
      add :owner, :string
      timestamps()
    end
    rename(table(:jobs), :dag_id, to: :job_id)

    alter table(:tasks) do
      remove :dag_id
    end

    alter table(:jobs) do
      remove :name
      remove :enabled

    end

    alter table(:tasks) do
      add :job_id, references(:jobs, column: :job_id, type: :binary_id)
    end


  end
end
