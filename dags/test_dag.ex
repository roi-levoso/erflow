defmodule TestDag do
  @behaviour Erflow.Base.Dag
  import Erflow.Base.Dag
  import Erflow.Base.Task

  @impl Erflow.Base.Dag
  def build() do
    t1 = Erflow.Base.Task.new(%{name: "task1", mod: "TestDag", fun: "fun"})
    t2 = Erflow.Base.Task.new(%{name: "task2", mod: "TestDag", fun: "fun"})
    t3 = Erflow.Base.Task.new(%{name: "task3", mod: "TestDag", fun: "fun"})
    t4 = Erflow.Base.Task.new(%{name: "task4", mod: "TestDag", fun: "fun"})
    t5 = Erflow.Base.Task.new(%{name: "task5", mod: "TestDag", fun: "fun"})
    t6 = Erflow.Base.Task.new(%{name: "task6", mod: "TestDag", fun: "fun"})

    dag = Erflow.Base.Dag.new(%{name: "Test", schedule: "27 * * *"}, []) <|> [t1, t2] ~> t3 ~> [t5, t6] <|> t4
    {:ok, dag}

  end

  def fun() do
    # new_state = Enum.random(["green-dot", "red-dot", "gray-dot"])
    # Erflow.LiveUpdates.notify_live_view("state", {"state", [:dags, :updated], [new_state]})
    Process.sleep(25000)
    {:ok, "Perfect"}
  end
end
