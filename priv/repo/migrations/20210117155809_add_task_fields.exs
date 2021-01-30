defmodule Erflow.Repo.Migrations.AddTaskFields do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :mod, :string
      add :fun, :string
      add :args, {:array, :string}
    end
  end
end
