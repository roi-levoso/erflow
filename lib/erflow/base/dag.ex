defmodule Erflow.Base.Dag do
  alias Erflow.Base.Task, as: BaseTask
  defstruct [:name, :schedule, :graph]



    ################
  #Use it directly as with
  # defp compile(file) do
  #   case Kernel.ParallelCompiler.compile([file]) do
  #     {:ok, [module], message} -> {:ok, [module], message}
  #     {:error, message, _} -> {:error, message}
  #   end
  # end
  #################

  @callback build() :: {:ok, %__MODULE__{}} | {:error, String.t}

  def build!(implementation, contents) do
    IO.inspect(implementation)
    case implementation.build(contents) do
      {:ok, data} -> data
      {:error, error} -> raise ArgumentError, "Building error: #{error}"
    end
  end


  def build_dag_from_file(file) do
    with {:ok, [module], _} <- Kernel.ParallelCompiler.compile([file]),
          {:ok, base_dag} <- module.build()
    do
      {:ok, base_dag}
    else
      err -> err
      IO.inspect(err)
      nil
    end
  end


  def new(%{name: name, schedule: schedule}, tasks) do
    to_graph(tasks)
    |> is_acyclic(%__MODULE__{name: name, schedule: schedule, graph: nil})
  end
  def new(%{name: name}, tasks) do
    to_graph(tasks)
    |> is_acyclic(%__MODULE__{name: name, graph: nil})
  end

  def get_tasks(%__MODULE__{} = dag) do
    Graph.vertices(dag.graph)
  end
  def get_relations(%__MODULE__{} = dag, task) do
    Graph.edges(dag.graph, task)
    |> Enum.reduce(%{parent: [], child: []},fn x, acc -> update_relations_accumulator(x, acc, task) end)
  end
  defp update_relations_accumulator(dag, acc, task) when dag.v1.name== task.name do
    %{parent: acc.parent ++ [], child: acc.child ++ [dag.v2.name]}
  end
  defp update_relations_accumulator(dag, acc, task) when dag.v2.name== task.name do
    %{parent: acc.parent ++ [dag.v1.name], child: acc.child ++ []}
  end

  def set_relation(%__MODULE__{} = dag, %BaseTask{} = parent, %BaseTask{} = child) do
    dag.graph
    |> Graph.add_edge(Graph.Edge.new(parent, child))
    |> is_acyclic(dag)
  end
  def set_relation(%__MODULE__{} = dag, [%BaseTask{} = parent | tail], %BaseTask{} = child) do
    dag.graph
    |> Graph.add_edge(Graph.Edge.new(parent, child))
    |> is_acyclic(dag)
    |> set_relation(tail, child)
  end
  def set_relation(%__MODULE__{} = dag, %BaseTask{} = parent, [%BaseTask{} = child | tail]) do
    dag.graph
    |> Graph.add_edge(Graph.Edge.new(parent, child))
    |> is_acyclic(dag)
    |> set_relation(parent, tail)
  end
  def set_relation(%__MODULE__{} = dag, [], _) do
    dag
  end
  def set_relation(%__MODULE__{} = dag, _, []) do
    dag
  end


  def add_task(%__MODULE__{} = dag, %BaseTask{} = task) do
    dag.graph
    |> Graph.add_vertex(task)
    |> is_acyclic(dag)
  end
  def add_task(%__MODULE__{} = dag, [%BaseTask{}=head | tail]) do
    dag.graph
    |> Graph.add_vertex(head)
    |> is_acyclic(dag)
    |> add_task(tail)
  end
  def add_task(%__MODULE__{} = dag, []) do
    dag
  end


  def a <|> b, do: erflow_operator(a, b)
  def %{dag: dag, parent: parent} ~> child, do: relation_operator(%{dag: dag, parent: parent}, child)

  defp relation_operator(%{dag: %__MODULE__{} = dag, parent: %BaseTask{} = parent}, %BaseTask{} = child) do
    new_dag = set_relation(dag, parent, child)
    %{dag: new_dag, parent: child}
  end
  defp relation_operator(%{dag: %__MODULE__{} = dag, parent: parents}, %BaseTask{} = child) do
    new_dag = set_relation(dag, parents, child)
    %{dag: new_dag, parent: child}
  end
  defp relation_operator(%{dag: %__MODULE__{} = dag, parent: %BaseTask{} = parent}, childs) do
    new_dag = set_relation(dag, parent, childs)
    %{dag: new_dag, parent: childs}
  end

  def erflow_operator(%__MODULE__{} = dag, task) do
    start_dag(dag, task)
  end
  def erflow_operator(%{dag: %__MODULE__{} = dag, parent: parent}, child) do
    set_relation(dag, parent, child)
  end

  defp start_dag(%__MODULE__{} = dag, %BaseTask{} = task) do
    new_dag = add_task(dag, task)
    %{dag: new_dag, parent: task}
  end
  defp start_dag(%__MODULE__{} = dag, tasks) do
    new_dag = add_task(dag, tasks)
    %{dag: new_dag, parent: tasks}
  end

  defp is_acyclic(graph, %__MODULE__{} = dag) do
    graph
    |> Graph.is_acyclic?
    |> case do
        true  -> %__MODULE__{dag | graph: graph}
        false -> raise("Contains cycles")
       end
  end

  defp to_graph(tasks) do
    tasks
    |> Enum.reduce(Graph.new(type: :directed), fn(task, acc)
      -> add_task(acc, task) end)
  end

end
