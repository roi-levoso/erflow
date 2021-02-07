defmodule TestDag do
  @behaviour Erflow.Base.Job
  import Erflow.Base.Dag

  @impl Erflow.Base.Job
  def build() do
    t1 = new_task(%{name: "task1", mod: "TestDag", fun: "fun"})
    t2 = new_task(%{name: "task2", mod: "TestDag", fun: "fun"})
    t3 = new_task(%{name: "task3", mod: "TestDag", fun: "fun"})
    t4 = new_task(%{name: "task4", mod: "TestDag", fun: "fun"})
    t5 = new_task(%{name: "task5", mod: "TestDag", fun: "fun"})
    t6 = new_task(%{name: "task6", mod: "TestDag", fun: "fun"})

    dag = Erflow.Base.Dag.new(%{name: "Test", schedule: "28 * * *"}, []) <|> [t1, t2] ~> t3 ~> [t5, t6] <|> t4
    {:ok, dag}

  end

  def fun() do
    # new_state = Enum.random(["green-dot", "red-dot", "gray-dot"])
    # Erflow.LiveUpdates.notify_live_view("state", {"state", [:dags, :updated], [new_state]})
    Process.sleep(25000)
    {:ok, "Perfect"}
  end
end
