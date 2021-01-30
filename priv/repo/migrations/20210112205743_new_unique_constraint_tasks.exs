defmodule Erflow.Repo.Migrations.NewUniqueConstraintTasks do
  use Ecto.Migration

  def change do

    alter table(:tasks) do
      remove :job_id
    end
    rename table(:running_tasks), :job, to: :job_id
    rename table(:running_tasks), :task, to: :task_id

    create unique_index(:tasks, [:dag_id, :name], name: :unique_task_per_dag)
    create unique_index(:running_tasks, [:job_id, :task_id], name: :unique_task_per_job)
  end
end
