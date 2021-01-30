defmodule Erflow.Repo.Migrations.RemoveUnnecesaryKey do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE tasks DROP CONSTRAINT tasks_job_id_fkey"
  end
end
