defmodule Erflow.Repo.Migrations.RemoveDefaultPrimaryKey do
  use Ecto.Migration

  def change do
    alter table(:running_tasks,  primary_key: false) do
      remove :runningtask_id
      add :runningtask_id, :binary_id, primary_key: true
    end
  end
end
