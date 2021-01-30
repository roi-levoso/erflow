defmodule Scheduler.DagsWatcher do
  use GenServer
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
    |> Enum.map(&build_dag/1)
    |> Enum.filter(&!is_nil(&1))
    |> Enum.map(&upsert_dag/1)
    |> Enum.each(&Scheduler.Cron.update_dag/1)

    {:ok, watcher_pid} = FileSystem.start_link(dirs: [@dags_dir])
    FileSystem.subscribe(watcher_pid)
    {:ok, []}
  end

    # TODO How to deal with duplicate modules?
    # TODO Propagate errors to the web
  defp build_dag(file) do
    with {:ok, [module], _} <- compile(file),
          {:ok, base_dag} <- module.build()
    do
      {:ok, base_dag}
    else
      err -> err
      IO.inspect(err)
      nil
    end
  end


  defp compile(file) do
    case Kernel.ParallelCompiler.compile([file]) do
      {:ok, [module], message} -> {:ok, [module], message}
      {:error, message, _} -> {:error, message}
    end
  end

  def handle_info({:file_event, _watcher_pid, {path, events}}, state) do
    dag = handle_event({events, path})

    {:noreply, state ++ [dag] |> Enum.filter(&!is_nil(&1))}
  end

  defp handle_event({events, path}) do
    case List.last(events) do
      :removed ->
        nil
      :created ->
        # TODO Create new dag(if not exists, in other case update) in database
        # TODO check if the build dag is correct befor upserting it
        path |> Path.wildcard() |> build_dag() |> upsert_dag() |> Scheduler.Cron.update_dag()
      :modified ->
        # TODO Update dag in database
        # TODO check if the build dag is correct befor upserting it
        path |> Path.wildcard() |> build_dag() |> upsert_dag() |> Scheduler.Cron.update_dag()
      _ ->
        nil
    end
  end

  defp upsert_dag({_, base_dag}) do
    # TODO Consider using hash to control this update. It save resources
    # TODO Remove tasks not contained in the dag when updated
    # TODO refactor to update tasks within a transaction
    Erflow.Core.create_dag(%{name: base_dag.name, schedule: base_dag.schedule})
    |> case do
      {:ok, dag} -> Erflow.Dag.BaseDag.get_tasks(base_dag)
      |> Enum.map(fn task -> upsert_task(task, dag.dag_id) end)
      |> upsert_relations(base_dag)
      {:error,_error} -> raise "Error"
    end
    base_dag
  end
  defp upsert_task(task, dag_id) do
    Erflow.Core.create_task(%{name: task.name,
     mod: task.mod,
    fun: task.fun,
    args: task.args,
    dag_id: dag_id})
    |> case do
      {:ok, db_task} -> %{graph_task: task, db_task: db_task}
      {:error,_error} -> raise "Error"
    end
  end
  defp upsert_relations(created_tasks, base_dag) do
    created_tasks
    |> Enum.map(&remove_relations/1)
    |> Enum.map(fn task -> upsert_relation(task, created_tasks, base_dag) end)

  end
  defp remove_relations(created_task) do
    Erflow.Core.get_all_relations_by_task_id(created_task.db_task.task_id)
    |> Enum.each(&Erflow.Core.delete_tasks_tasks/1)
    created_task
  end
  defp upsert_relation(created_task, db_tasks, base_dag) do
    with %{parent: graph_parent, child: graph_child} <- Erflow.Dag.BaseDag.get_relations(base_dag, created_task.graph_task),
    %{parent: db_parent_ids, child: db_child_ids} <- get_relation_ids(%{parent: graph_parent, child: graph_child}, db_tasks)
    do

      db_child_ids
      |> Enum.each(fn child -> Erflow.Core.create_tasks_tasks(%{child_id: child, parent_id: created_task.db_task.task_id}) end)

      db_parent_ids
      |> Enum.each(fn parent -> Erflow.Core.create_tasks_tasks(%{parent_id: parent, child_id: created_task.db_task.task_id}) end)

    end
  end
  defp get_relation_ids(%{parent: graph_parent, child: graph_child}, tasks) do
    with child_ids <- graph_child
    |> Enum.map(fn child -> Enum.find(tasks, fn task -> task.db_task.name==child end) end)
    |> Enum.map(fn task -> task.db_task.task_id end),
    parent_ids <- graph_parent
    |> Enum.map(fn parent -> Enum.find(tasks, fn task -> task.db_task.name==parent end) end)
    |> Enum.map(fn task -> task.db_task.task_id end)
    do
      %{parent: parent_ids, child: child_ids}
    end
  end

end
