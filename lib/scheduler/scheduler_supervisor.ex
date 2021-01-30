defmodule Scheduler.SchedulerSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Scheduler.JobSupervisor, name: Scheduler.JobSupervisor},
      {Scheduler.Cron, name: Scheduler.Cron},
      {Scheduler.DagsWatcher, name: Scheduler.DagsWatcher}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
