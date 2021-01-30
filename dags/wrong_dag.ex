defmodule TestDagWrong do
  @behaviour Erflow.Dag.BaseJob
  import Erflow.Dag.BaseDag


  @impl Erflow.Dag.BaseJob
  def build() do
    t1 = new_task(%{name: :task1})
    t2 = new_task(%{name: :task2})
    t3 = new_task(%{name: :task3})
    t4 = new_task(%{name: :task4})

    dag = Erflow.Dag.BaseDag.new(%{name: "test2"}, []) <|> [t1, t2] ~> t3 <|> t4
    {:ok, dag}
  end
end
