defmodule Erflow.Model do
  @moduledoc """
  The Model context.
  """

  import Ecto.Query, warn: false
  alias Erflow.Repo

  alias Erflow.Model.Dag
  alias Erflow.Model.Job
  alias Erflow.Model.Task


    @doc """
  Returns the list of dags.

  ## Examples

      iex> list_dags()
      [%Dag{}, ...]

  """
  def list_dags do
    Repo.all(Dag)
  end

  @doc """
  Gets a single dag.

  Raises `Ecto.NoResultsError` if the dag does not exist.

  ## Examples

      iex> get_dag!(123)
      %Dag{}

      iex> get_dag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dag!(id), do: Repo.get!(Dag, id)

    @doc """
  Gets a single dag by name.

  ## Examples

      iex> get_dag_by_name(sample)
      {:ok, %Dag{}}

      iex> get_dag_by_name(wrong_sample)
      {:error, nil}

  """
  def get_dag_by_name(dag_name) do
    Dag
    |> Repo.get_by(name: dag_name)
    |> case do
      nil -> {:error, nil}
      dag -> {:ok, dag}
    end
  end
  @spec create_dag(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          any
  @doc """
  Creates a dag.

  ## Examples

      iex> create_dag(%{field: value})
      {:ok, %Dag{}}

      iex> create_dag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dag(attrs \\ %{}) do
    %Dag{}
    |> Dag.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace, [:schedule, :owner, :enabled]},
      conflict_target: :name,
      returning: true
    )
  end

  @doc """
  Updates a dag.

  ## Examples

      iex> update_dag(Dag, %{field: new_value})
      {:ok, %Dag{}}

      iex> update_dag(Dag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dag(%Dag{} = dag, attrs) do
    dag
    |> Dag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a dag.

  ## Examples

      iex> delete_dag(Dag)
      {:ok, %Dag{}}

      iex> delete_dag(Dag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dag(%Dag{} = dag) do
    Repo.delete(Dag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dag changes.

  ## Examples

      iex> change_dag(Dag)
      %Ecto.Changeset{data: %Dag{}}

  """
  def change_dag(%Dag{} = dag, attrs \\ %{}) do
    dag.changeset(Dag, attrs)
  end


  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Repo.all(Job)
  end

    @doc """
  Returns the list of jobs with status as running.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_running_jobs do
    Job
    |> where(status: "running")
    |> Repo.all()
    |> Repo.preload(:dag)
  end

  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(id), do: Repo.get!(Job, id)

  @spec create_job(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          any
  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(attrs \\ %{}) do
    %Job{}
    |> Repo.preload(:dag)
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(Job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(Job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job.

  ## Examples

      iex> delete_job(Job)
      {:ok, %Job{}}

      iex> delete_job(Job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Job{} = job) do
    Repo.delete(Job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(Job)
      %Ecto.Changeset{data: %Job{}}

  """
  def change_job(%Job{} = job, attrs \\ %{}) do
    job.changeset(Job, attrs)
  end



  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task)
  end

      @doc """
  Returns the list of tasks of a given dag_id.

  ## Examples

      iex> get_tasks_by_dag(dag_id)
      [%Task{}, ...]

  """
  def get_tasks_by_dag(dag_id) do
    Task
    |> where(dag_id: ^dag_id)
    |> Repo.all()
    |> Repo.preload(:parent)
    |> Repo.preload(:child)

  end



  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do

    %Task{}
    |> Repo.preload(:dag)
    |> Task.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace, [:mod, :fun, :args]},
      conflict_target: [:name, :dag_id],
      returning: true
    )
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  alias Erflow.Model.TasksTasks

  @doc """
  Returns the list of tasks_taskss.

  ## Examples

      iex> list_tasks_taskss()
      [%TasksTasks{}, ...]

  """
  def list_tasks_tasks do
    Repo.all(TasksTasks)
  end

    @doc """
  Returns the list of tasks_tasks that match task id on parent or child.

  ## Examples

      iex> get_all_relations_by_task_id(task_id)
      [%TasksTasks{}, ...]

  """
  def get_all_relations_by_task_id(task_id) do
    query = from relation in TasksTasks,
     where: relation.parent_id==^task_id or relation.child_id==^task_id,
     select: relation
     Repo.all(query)
  end

  @doc """
  Gets a single tasks_tasks.

  Raises `Ecto.NoResultsError` if the TasksTasks does not exist.

  ## Examples

      iex> get_tasks_tasks!(123)
      %TasksTasks{}

      iex> get_tasks_tasks!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tasks_tasks!(id), do: Repo.get!(TasksTasks, id)

  @doc """
  Creates a tasks_tasks.

  ## Examples

      iex> create_tasks_tasks(%{field: value})
      {:ok, %TasksTasks{}}

      iex> create_tasks_tasks(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tasks_tasks(attrs \\ %{}) do
    %TasksTasks{}
    |> TasksTasks.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tasks_tasks.

  ## Examples

      iex> update_tasks_tasks(tasks_tasks, %{field: new_value})
      {:ok, %TasksTasks{}}

      iex> update_tasks_tasks(tasks_tasks, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tasks_tasks(%TasksTasks{} = tasks_tasks, attrs) do
    tasks_tasks
    |> TasksTasks.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tasks_tasks.

  ## Examples

      iex> delete_tasks_tasks(tasks_tasks)
      {:ok, %TasksTasks{}}

      iex> delete_tasks_tasks(tasks_tasks)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tasks_tasks(%TasksTasks{} = tasks_tasks) do
    Repo.delete(tasks_tasks)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tasks_tasks changes.

  ## Examples

      iex> change_tasks_tasks(tasks_tasks)
      %Ecto.Changeset{data: %TasksTasks{}}

  """
  def change_tasks_tasks(%TasksTasks{} = tasks_tasks, attrs \\ %{}) do
    TasksTasks.changeset(tasks_tasks, attrs)
  end

  alias Erflow.Model.RunningTask

  @doc """
  Returns the list of running_tasks.

  ## Examples

      iex> list_running_tasks()
      [%RunningTask{}, ...]

  """
  def list_running_tasks do
    Repo.all(RunningTask)
  end

    @doc """
  Returns the list of tasks of a given dag which doesn't have parent tasks.

  ## Examples

      iex> get_initial_dag_tasks(dag_id)
      [%Task{}, ...]

  """
  def get_running_tasks_by_job(job_id) do
    RunningTask
    |> where(job_id: ^job_id)
    |> Repo.all()
    |> Repo.preload(:task)
  end

  @doc """
  Gets a single running_task.

  Raises `Ecto.NoResultsError` if the RunningTask does not exist.

  ## Examples

      iex> get_running_task!(123)
      %RunningTask{}

      iex> get_running_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_running_task!(id), do: Repo.get!(RunningTask, id)

  def get_running_task_by_job_and_task!(%{job: job, task: task}), do: Repo.get_by!(RunningTask, [job_id: job, task_id: task])

  @doc """
  Creates a running_task.

  ## Examples

      iex> create_running_task(%{field: value})
      {:ok, %RunningTask{}}

      iex> create_running_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_running_task(attrs \\ %{}) do
    %RunningTask{}
    |> RunningTask.changeset(attrs)
    |> Repo.insert!(
      on_conflict: :nothing,
      returning: true
    )
    |> Repo.preload(:task)
  end

  @doc """
  Updates a running_task.

  ## Examples

      iex> update_running_task(running_task, %{field: new_value})
      {:ok, %RunningTask{}}

      iex> update_running_task(running_task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_running_task(%RunningTask{} = running_task, attrs) do
    running_task
    |> RunningTask.changeset(attrs)
    |> Repo.update!(
      returning: true
    )
  end

  @doc """
  Deletes a running_task.

  ## Examples

      iex> delete_running_task(running_task)
      {:ok, %RunningTask{}}

      iex> delete_running_task(running_task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_running_task(%RunningTask{} = running_task) do
    Repo.delete(running_task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking running_task changes.

  ## Examples

      iex> change_running_task(running_task)
      %Ecto.Changeset{data: %RunningTask{}}

  """
  def change_running_task(%RunningTask{} = running_task, attrs \\ %{}) do
    RunningTask.changeset(running_task, attrs)
  end
end
