
defmodule Jobs.TaskRunner do
  use GenServer
  alias Erflow.Core.Job

  def start_link(%Job{} = job) do
    runner = String.to_atom(job.job_id <> "_runner")
    GenServer.start_link(__MODULE__, job, [name: runner])
  end

  def init(%Job{} = job), do: {:ok, job}

  def run(fun) do
    GenServer.cast(self(), {:run, fun})
  end


  def handle_cast({:run, running_task}, state) do
    Erflow.Core.get_running_task_by_job_and_task!(%{job: running_task.job_id, task: running_task.task_id})
    |> Erflow.Core.update_running_task(%{status: "running"})
    |> run_task(running_task.task.mod, running_task.task.fun, running_task.task.args)
    {:noreply, state}
  end

  defp run_task(running_task, module, fun, _args) when is_nil(fun) or is_nil(module) do
    Task.async(fn -> {:ok, running_task} end)
  end
  defp run_task(running_task, module, fun, _args) do
    Task.async(fn ->
        try do
        apply(String.to_existing_atom("Elixir."<>module), String.to_atom(fun), [])
        {:ok, running_task}
        rescue
          _error -> {:error, running_task}
        end
      end)
  end


  def handle_info({_task, {:ok, running_task}}, state) do
    Erflow.Core.update_running_task(running_task, %{status: "done"})
    IO.puts("Job Done.")
    {:noreply, state}
  end

  def handle_info({_task, {:error, running_task}}, state) do
    Erflow.Core.update_running_task(running_task, %{status: "failed"})
    IO.puts("Failed to completed job")
    {:noreply, state}
  end

  def handle_info(_, state), do:  {:noreply, state}

end
