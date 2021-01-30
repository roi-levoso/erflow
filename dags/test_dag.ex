defmodule TestDag do
  @behaviour Erflow.Dag.BaseJob
  import Erflow.Dag.BaseDag

  @impl Erflow.Dag.BaseJob
  def build() do
    t1 = new_task(%{name: "task1", mod: "TestDag", fun: "fun"})
    t2 = new_task(%{name: "task2", mod: "TestDag", fun: "fun"})
    t3 = new_task(%{name: "task3", mod: "TestDag", fun: "fun"})
    t4 = new_task(%{name: "task4", mod: "TestDag", fun: "fun"})
    t5 = new_task(%{name: "task5", mod: "TestDag", fun: "fun"})
    t6 = new_task(%{name: "task6", mod: "TestDag", fun: "fun"})

    dag = Erflow.Dag.BaseDag.new(%{name: "Test", schedule: "40 * * *"}, []) <|> [t1, t2] ~> t3 ~> [t5, t6] <|> t4
    {:ok, dag}

  end

  def fun() do
    # new_state = Enum.random(["green-dot", "red-dot", "gray-dot"])
    # Erflow.LiveUpdates.notify_live_view("state", {"state", [:dags, :updated], [new_state]})
    Process.sleep(25000)
    1/0
    {:ok, "Perfect"}
  end
end
