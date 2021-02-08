defmodule Scheduler.DagsWatcher do
  use GenServer
  alias Erflow.Base.Dag, as: BaseDag
  alias Erflow.Model, as: Model
  # TODO pass this variable through configuration
  @dags_dir  "/Users/roi.fernandez/Courses/Elixir/erflow/dags"
  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  @spec init(any) :: {:ok, [any]}
  def init(args) do
    # TODO pass dirs as config and check dir exists
    @dags_dir
    |> Path.join("*.ex")
    |> Path.wildcard()
    |> Enum.each(&base_dag_to_model/1)

    {:ok, watcher_pid} = FileSystem.start_link(dirs: [@dags_dir])
    FileSystem.subscribe(watcher_pid)
    {:ok, []}
  end


  # TODO How to deal with duplicate modules?
  # TODO Propagate errors to the web
  def handle_info({:file_event, _watcher_pid, {path, events}}, state) do
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
    {:noreply, []}
  end

  defp base_dag_to_model(file) do
    BaseDag.build_dag_from_file(file)
    |> Model.upsert_dag()
    |> Scheduler.Cron.update_dag()
  end

end
