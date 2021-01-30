defmodule Erflow.Repo.Migrations.AddIndexToTaskTasks do
  use Ecto.Migration

  def change do
    create unique_index(:tasks_tasks, [:child, :parent], name: :unique_child_and_parent)
  end
end
