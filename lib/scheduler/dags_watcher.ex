defmodule Scheduler.DagsWatcher do
  use GenServer
  alias Erflow.Base.Dag, as: BaseDag
  alias Erflow.Model, as: Model

  def start_link(opts \\ %{}) do
    with dags_dir <- Application.fetch_env!(:erflow, :dags_dir) do
      GenServer.start_link(__MODULE__, %{watcher: FileSystem, dags_dir: dags_dir}, [])
    end
  end

  @spec init(any) :: {:ok, [any]}
  def init(%{watcher: watcher, dags_dir: dags_dir}) do
    with dags_path <- Path.absname(dags_dir),
        :ok <- initialize_dags(dags_path),
        :ok <- initialize_watcher(watcher, dags_path) do
      {:ok, dags_path}
    else
      error -> {:error, "#{dags_dir} does not exist"}
    end
  end

  defp initialize_dags(dags_path) do
    with true <- File.exists?(dags_path) do
      dags_path
      |> Path.join("*.ex")
      |> Path.wildcard()
      |> Enum.each(&base_dag_to_model/1)
    else
      error -> {:error, error}
    end
  end

  defp initialize_watcher(watcher, dags_path) do
    with {:ok, watcher_pid} <- watcher.start_link(dirs: [dags_path]) do
      watcher.subscribe(watcher_pid)
    else
      error -> {:error, dags_path}
    end
  end

  # TODO How to deal with duplicate modules?
  # TODO Propagate errors to the web
  def handle_info({:file_event, _watcher_pid, {path, events}}, dags_path) do
    case List.last(events) do
      :removed ->
        nil

      :created ->
        # TODO check if the build dag is correct before upserting it
        path |> Path.wildcard() |> base_dag_to_model()

      :modified ->
        # TODO check if the build dag is correct before upserting it
        path |> Path.wildcard() |> base_dag_to_model()

      _ ->
        nil
    end

    {:noreply, dags_path}
  end

  defp base_dag_to_model(file) do
    file
    |> BaseDag.build_dag_from_file()
    |> Model.upsert_dag()
    |> Scheduler.Cron.update_dag()
    :ok
  end
end
