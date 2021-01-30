defmodule Erflow.Repo.Migrations.AddDagsDefinitionTable do
  use Ecto.Migration

  def change do
    rename table(:dags), to: table(:jobs)


  end
end
