defmodule TestDagWrong do
  @behaviour Erflow.Base.Dag
  import Erflow.Base.Dag


  @impl Erflow.Base.Dag
  def build() do
    t1 = Erflow.Base.Task.new(%{name: :task1})
    t2 = Erflow.Base.Task.new(%{name: :task2})
    t3 = Erflow.Base.Task.new(%{name: :task3})
    t4 = Erflow.Base.Task.new(%{name: :task4})

    dag = Erflow.Base.Dag.new(%{name: "test2"}, []) <|> [t1, t2] ~> t3 <|> t4
    {:ok, dag}
  end
end
