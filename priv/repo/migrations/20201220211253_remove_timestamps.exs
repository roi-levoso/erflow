defmodule Erflow.Repo.Migrations.RemoveTimestamps do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      remove :inserted_at
      remove :updated_at
    end

    alter table(:relationships) do
      remove :inserted_at
      remove :updated_at
    end

  end
end
