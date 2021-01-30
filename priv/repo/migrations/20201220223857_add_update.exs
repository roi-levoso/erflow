defmodule Erflow.Repo.Migrations.AddUpdate do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE relationships DROP CONSTRAINT relationships_parent_fkey"
    execute "ALTER TABLE relationships DROP CONSTRAINT relationships_child_fkey"
    alter table(:relationships) do
      modify :parent, references(:tasks, on_delete: :delete_all, column: :task_id, type: :binary_id)
      modify :child, references(:tasks, on_delete: :delete_all, column: :task_id, type: :binary_id)
    end

  end
end
