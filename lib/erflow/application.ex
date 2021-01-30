defmodule Erflow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Erflow.Repo,
      # Start the Telemetry supervisor
      ErflowWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Erflow.PubSub},
      # Start the Endpoint (http/https)
      ErflowWeb.Endpoint,
      # Start a worker by calling: Erflow.Worker.start_link(arg)
      # {Erflow.Worker, arg}
      # Start Scheduler Supervisor
      Scheduler.SchedulerSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Erflow.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ErflowWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
