defmodule Erflow.Repo.Migrations.AddOrderTotasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :priority, :integer
    end
  end
end
