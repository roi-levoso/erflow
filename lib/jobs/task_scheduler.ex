defmodule Jobs.TaskScheduler do
  use GenServer
  alias Erflow.Core.Job

  defstruct [:job, :runner]

  @type t :: %__MODULE__{
    job: Job,
    runner: String.t(),
  }


  def start_link(%Job{} = job) do
    scheduler = String.to_atom(job.job_id <> "_scheduler")
    runner = String.to_atom(job.job_id <> "_runner")
    GenServer.start_link(__MODULE__, %{job: job, runner: runner}, [name: scheduler])
  end

  @impl true
  @spec init(%{job: any, runner: any}) :: {:ok, Job.TaskScheduler.t()}
  def init(%{job: job, runner: runner}) do

    tasks = Erflow.Core.get_tasks_by_dag(job.dag_id)

    tasks
    |> Enum.map(fn task -> Erflow.Core.create_running_task(%{job_id: job.job_id, task_id: task.task_id}) end)

    running_tasks= Erflow.Core.get_running_tasks_by_job(job.job_id)

    running_tasks
    |> Enum.filter(fn running_task -> running_task.status=="running" end)
    |> case do
      [] -> find_next_tasks(running_tasks, tasks)
      init_tasks -> init_tasks
    end
    |> Enum.map(fn running_task -> run_task(running_task, runner) end)
    schedule_work()
    {:ok, %__MODULE__{job: job, runner: runner}}
  end

  defp find_next_tasks(running_tasks, tasks) do

    case Enum.filter(running_tasks, fn running_task -> !is_nil(running_task.status) end) do
      [] -> get_start_tasks(running_tasks, tasks)
      _ -> calculate_next_tasks(running_tasks, tasks)
    end
  end

  defp get_start_tasks(running_tasks, tasks) do
    tasks
    |> Enum.filter(fn task -> task.parent == [] end)
    |> Enum.map(fn task -> Enum.find(running_tasks, fn running_task -> task.task_id==running_task.task_id end) end)

  end
  defp calculate_next_tasks(running_tasks, tasks) do

    Enum.filter(running_tasks, fn running_task -> is_nil(running_task.status) end)
    |> Enum.filter(fn running_task -> is_task_allowed_to_run(running_task ,running_tasks, tasks) end)
  end

  #TODO Add more cases. Now only allowed to run a task if all their parets are done, but add ANY logic
  defp is_task_allowed_to_run(checking_task ,running_tasks, tasks) do

    task = tasks
    |> Enum.find(fn task -> task.task_id==checking_task.task_id end)

    # If task child is NULL
    child_condition = task.child
    |> Enum.map(fn child -> Enum.find(running_tasks, fn running_task -> child.task_id==running_task.task_id end) end)
    |> Enum.filter(fn t-> !is_nil(t.status) end)
    |> case do
      [] -> true
      _ -> false
    end
    # If all the parents are DONE
    parent_condition = task.parent
    |> Enum.map(fn parent -> Enum.find(running_tasks, fn running_task -> parent.task_id==running_task.task_id end) end)
    |> Enum.filter(fn t-> not (t.status=="done") end)
    |> case do
      [] -> true
      _ -> false
    end

    child_condition and parent_condition

  end
  @impl true
  def handle_info(:work, %{job: job, runner: runner} = state) do

    tasks = Erflow.Core.get_tasks_by_dag(job.dag_id)
    # QUESTION Is it necessary to update running_jobs every loop step or only on init?
    tasks
    |> Enum.map(fn task -> Erflow.Core.create_running_task(%{job_id: job.job_id, task_id: task.task_id}) end)

    running_tasks= Erflow.Core.get_running_tasks_by_job(job.job_id)

    pid = String.to_atom(job.job_id <> "_supervisor")
          |> Process.whereis()
    case update_job_status(running_tasks, job) do
      [] -> ""
      _ ->  DynamicSupervisor.terminate_child(Elixir.Scheduler.JobSupervisor, pid)
    end

    find_next_tasks(running_tasks, tasks)
    |> Enum.map(fn running_task -> run_task(running_task, runner) end)

    schedule_work()
    {:noreply, state}
  end

  defp update_job_status(running_tasks, job) do
    # TODO if job is failed or done destroy process supervisor
    cond do
      Enum.filter(running_tasks, fn task -> task.status == "failed" end) != [] -> Erflow.Core.get_job!(job.job_id) |> Erflow.Core.update_job(%{status: "failed"})
      Enum.filter(running_tasks, fn task -> not (task.status == "done") end) == [] -> Erflow.Core.get_job!(job.job_id) |> Erflow.Core.update_job(%{status: "done"})
      true -> []
    end

  end

  defp run_task(running_task, runner) do
    GenServer.cast(runner, {:run, running_task})
  end

  defp schedule_work do
    Process.send_after(self(), :work, :timer.seconds(10))
  end


end
