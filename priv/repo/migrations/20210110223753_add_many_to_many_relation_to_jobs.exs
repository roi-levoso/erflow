defmodule Erflow.Repo.Migrations.AddManyToManyRelationToJobs do
  use Ecto.Migration

  def change do
    create table(:tasks_tasks) do
      add :parent, references(:tasks, on_delete: :delete_all, column: :task_id, type: :binary_id)
      add :child, references(:tasks, on_delete: :delete_all, column: :task_id, type: :binary_id)
    end

    create table(:jobs_tasks) do
      add :task, references(:tasks, on_delete: :delete_all, column: :task_id, type: :binary_id)
      add :job, references(:jobs, on_delete: :delete_all, column: :job_id, type: :binary_id)
    end

    alter table(:tasks) do
      add :dag_id, references(:dags, column: :dag_id, type: :binary_id)
      remove :status

    end

    alter table(:jobs) do
      add :running_tasks, :binary_id
    end

    drop table(:relationships)

    create index(:tasks_tasks, [:parent])
    create index(:tasks_tasks, [:child])
    create index(:jobs_tasks, [:job])
    create index(:jobs_tasks, [:task])


  end
end
