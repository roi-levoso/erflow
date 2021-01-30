defmodule Erflow.Repo.Migrations.ModifyNamesTasksTasks do
  use Ecto.Migration

  def change do
    rename table(:tasks_tasks), :parent, to: :parent_id
    rename table(:tasks_tasks), :child, to: :child_id
  end
end
