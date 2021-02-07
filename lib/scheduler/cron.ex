defmodule Scheduler.Cron do
  use GenServer
  alias Erflow.Model.Dag
  alias Erflow.Model.Job


  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    # TODO Decide if all dags are loaded or only the ones existing in folder
    # # Get all the dags
    # dags = Erflow.Model.list_dags()

    # # Get next schedule time jobs and pass them as state
    # next_schedules = dags
    # |> Enum.map(&get_next_job/1)
    # #TODO Implement backfill

    # # Start running jobs
    Erflow.Model.list_running_jobs
    |> Enum.each(&run_job/1)
    # |> Enum.filter(fn job -> job.dag.enabled end)
    # # Start cron loop
    cron_loop()
    # {:ok, next_schedules}
    {:ok, []}
  end

  defp cron_loop do
    Process.send_after(self(), :cron_loop, :timer.seconds(10))
  end

  def run_job(%{} = job) do
    GenServer.cast(__MODULE__, {:run_job, job})
  end

  defp create_job(%{} = job) do
    new_job = Map.put(job, :start_time, DateTime.utc_now())
    with {:ok, created_job} <- Erflow.Model.create_job(new_job) do
      run_job(created_job)
      created_job
    else
      {:error, changeset} -> {:error, changeset}
      nil
    end
  end

  defp get_next_job(dag) do
    {:ok, schedule} = get_next_run_date(dag.schedule)
    %{scheduled_time: schedule, dag_id: dag.dag_id, status: "running"}
  end

  defp get_next_run_date(cron_expression) do
    with {:ok, result} <- Crontab.CronExpression.Parser.parse cron_expression do
       Crontab.Scheduler.get_next_run_date(result)
      end
  end

  def terminate_job(job_id) do
    GenServer.cast(__MODULE__, {:terminate, job_id})
  end

  @impl true
  def handle_info(:cron_loop, scheduled_jobs) do

    new_jobs = scheduled_jobs
    |> Enum.filter(fn job -> DateTime.compare(DateTime.from_naive!(job.scheduled_time, "Etc/UTC"), DateTime.utc_now()) == :lt end)
    |> Enum.map(&create_job/1)

    new_schedules = update_schedule(new_jobs, scheduled_jobs)

    cron_loop()
    {:noreply, new_schedules}
  end


  @impl true
  def handle_cast({:run_job, %{} = job}, state) do
    Scheduler.JobSupervisor.start_child({:supervisor, job})
    {:noreply, state}
  end

  # @impl true
  # def handle_cast({:terminate, dag_id}, state) do
  #   supervisor = String.to_atom(dag_id <> "_supervisor")
  #   pid = Process.whereis(supervisor)
  #   DynamicSupervisor.terminate_child(Elixir.Scheduler.JobSupervisor, pid)
  #   {:noreply, state}
  # end

  defp update_schedule(new_jobs, scheduled_jobs) when new_jobs == [] do
    scheduled_jobs
  end
  defp update_schedule(new_jobs, scheduled_jobs) do
    new_schedules = new_jobs
    |> Enum.filter(fn job -> job != nil end)
    |> Enum.map(&new_schedule/1)

    filtered_passed_schedules = scheduled_jobs
    |> Enum.filter(fn job -> DateTime.compare(DateTime.from_naive!(job.scheduled_time, "Etc/UTC"), DateTime.utc_now()) == :gt end)

    new_schedules ++ filtered_passed_schedules
  end

  defp new_schedule(job) do
    Erflow.Model.get_dag!(job.dag_id)
    |> get_next_job()
  end

  def update_dag(dag) do
    GenServer.cast(__MODULE__, {:update_dag, dag.name})
  end

  @impl true
  def handle_cast({:update_dag, dag_name}, scheduled_jobs) do
    new_scheduled_jobs =
    with {:ok, dag} <- Erflow.Model.get_dag_by_name(dag_name)
    do
      case dag.schedule do
        nil -> scheduled_jobs
        _ -> get_next_job(dag) |> append_job_if_not_exists(scheduled_jobs)
      end
    else
      _err->_err
      scheduled_jobs
    end
    {:noreply, new_scheduled_jobs}
  end
  defp append_job_if_not_exists(job, scheduled_jobs) do
    case Enum.member?(scheduled_jobs, job) do
      true -> scheduled_jobs
      false -> scheduled_jobs ++ [job]
    end
  end
end
