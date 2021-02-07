defmodule Scheduler.ProcessSupervisor do
  # Automatically defines child_spec/1
  use Supervisor
  alias Erflow.Model.Job

  defstruct [:dag, :runner, :name]

  @type t :: %__MODULE__{
    runner: String.t(),
    name: String.t()
  }

  def start_link(%Job{} = job) do
    supervisor = String.to_atom(job.job_id <> "_supervisor")
    Supervisor.start_link(__MODULE__, job, [name: supervisor])
  end

  @impl true
  def init(%Job{} = job) do
    runner = String.to_atom(job.job_id <> "_runner")
    scheduler = String.to_atom(job.job_id <> "_scheduler")
    children = [
      %{id: scheduler, start: {Jobs.TaskRunner, :start_link, [job]}},
      %{id: runner, start: {Jobs.TaskScheduler, :start_link, [job]}}

    ]
    Supervisor.init(children, strategy: :one_for_all)
  end

end
