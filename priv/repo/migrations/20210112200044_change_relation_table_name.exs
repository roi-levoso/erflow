defmodule Erflow.Repo.Migrations.ChangeRelationTableName do
  use Ecto.Migration

  def change do
    rename table(:jobs_tasks), to: table(:running_tasks)
  end
end
