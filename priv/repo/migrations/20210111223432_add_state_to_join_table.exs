defmodule Erflow.Repo.Migrations.AddStateToJoinTable do
  use Ecto.Migration

  def change do
    alter table(:jobs_tasks) do
      add :status, :string
    end
  end
end
