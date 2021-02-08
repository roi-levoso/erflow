defmodule TestDagWrong do
  @behaviour Erflow.Base.Dag
  import Erflow.Base.Dag


  @impl Erflow.Base.Dag
  def build() do
    t1 = new_task(%{name: :task1})
    t2 = new_task(%{name: :task2})
    t3 = new_task(%{name: :task3})
    t4 = new_task(%{name: :task4})

    dag = Erflow.Base.Dag.new(%{name: "test2"}, []) <|> [t1, t2] ~> t3 <|> t4
    {:ok, dag}
  end
end
