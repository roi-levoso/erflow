defmodule Scheduler.JobSupervisor do
  # Automatically defines child_spec/1
  use DynamicSupervisor
  alias Erflow.Core.Job

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_child(any) :: :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start_child({:supervisor, %Job{} = job}) do
    supervisor = String.to_atom(job.job_id <> "_supervisor")
    spec = %{id: supervisor, start: {Scheduler.ProcessSupervisor, :start_link, [job]}, type: :supervisor}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
