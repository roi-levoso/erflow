defmodule Erflow.Repo.Migrations.FixType do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      modify :end_time, :utc_datetime
      modify :start_time, :utc_datetime
    end
  end
end
