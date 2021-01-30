defmodule Erflow.CoreTest do
  use Erflow.DataCase

  alias Erflow.Core

  describe "dags" do
    alias Erflow.Core.Dag

    @valid_attrs %{dag_id: "some dag_id", enabled: "some enabled", end_time: "some end_time", scheduled_time: "some scheduled_time", start_time: "some start_time", status: "some status"}
    @update_attrs %{dag_id: "some updated dag_id", enabled: "some updated enabled", end_time: "some updated end_time", scheduled_time: "some updated scheduled_time", start_time: "some updated start_time", status: "some updated status"}
    @invalid_attrs %{dag_id: nil, enabled: nil, end_time: nil, scheduled_time: nil, start_time: nil, status: nil}

    def dag_fixture(attrs \\ %{}) do
      {:ok, dag} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_dag()

      dag
    end

    test "list_dags/0 returns all dags" do
      dag = dag_fixture()
      assert Core.list_dags() == [dag]
    end

    test "get_dag!/1 returns the dag with given id" do
      dag = dag_fixture()
      assert Core.get_dag!(dag.id) == dag
    end

    test "create_dag/1 with valid data creates a dag" do
      assert {:ok, %Dag{} = dag} = Core.create_dag(@valid_attrs)
      assert dag.dag_id == "some dag_id"
      assert dag.enabled == "some enabled"
      assert dag.end_time == "some end_time"
      assert dag.scheduled_time == "some scheduled_time"
      assert dag.start_time == "some start_time"
      assert dag.status == "some status"
    end

    test "create_dag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_dag(@invalid_attrs)
    end

    test "update_dag/2 with valid data updates the dag" do
      dag = dag_fixture()
      assert {:ok, %Dag{} = dag} = Core.update_dag(dag, @update_attrs)
      assert dag.dag_id == "some updated dag_id"
      assert dag.enabled == "some updated enabled"
      assert dag.end_time == "some updated end_time"
      assert dag.scheduled_time == "some updated scheduled_time"
      assert dag.start_time == "some updated start_time"
      assert dag.status == "some updated status"
    end

    test "update_dag/2 with invalid data returns error changeset" do
      dag = dag_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_dag(dag, @invalid_attrs)
      assert dag == Core.get_dag!(dag.id)
    end

    test "delete_dag/1 deletes the dag" do
      dag = dag_fixture()
      assert {:ok, %Dag{}} = Core.delete_dag(dag)
      assert_raise Ecto.NoResultsError, fn -> Core.get_dag!(dag.id) end
    end

    test "change_dag/1 returns a dag changeset" do
      dag = dag_fixture()
      assert %Ecto.Changeset{} = Core.change_dag(dag)
    end
  end

  describe "tasks" do
    alias Erflow.Core.Task

    @valid_attrs %{dag_id: "some dag_id", end_time: "some end_time", name: "some name", scheduled_time: "some scheduled_time", start_time: "some start_time", status: "some status", task_id: "some task_id"}
    @update_attrs %{dag_id: "some updated dag_id", end_time: "some updated end_time", name: "some updated name", scheduled_time: "some updated scheduled_time", start_time: "some updated start_time", status: "some updated status", task_id: "some updated task_id"}
    @invalid_attrs %{dag_id: nil, end_time: nil, name: nil, scheduled_time: nil, start_time: nil, status: nil, task_id: nil}

    def task_fixture(attrs \\ %{}) do
      {:ok, task} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_task()

      task
    end

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Core.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Core.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      assert {:ok, %Task{} = task} = Core.create_task(@valid_attrs)
      assert task.dag_id == "some dag_id"
      assert task.end_time == "some end_time"
      assert task.name == "some name"
      assert task.scheduled_time == "some scheduled_time"
      assert task.start_time == "some start_time"
      assert task.status == "some status"
      assert task.task_id == "some task_id"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      assert {:ok, %Task{} = task} = Core.update_task(task, @update_attrs)
      assert task.dag_id == "some updated dag_id"
      assert task.end_time == "some updated end_time"
      assert task.name == "some updated name"
      assert task.scheduled_time == "some updated scheduled_time"
      assert task.start_time == "some updated start_time"
      assert task.status == "some updated status"
      assert task.task_id == "some updated task_id"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_task(task, @invalid_attrs)
      assert task == Core.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Core.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Core.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Core.change_task(task)
    end
  end

  describe "relationships" do
    alias Erflow.Core.Relationship

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def relationship_fixture(attrs \\ %{}) do
      {:ok, relationship} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_relationship()

      relationship
    end

    test "list_relationships/0 returns all relationships" do
      relationship = relationship_fixture()
      assert Core.list_relationships() == [relationship]
    end

    test "get_relationship!/1 returns the relationship with given id" do
      relationship = relationship_fixture()
      assert Core.get_relationship!(relationship.id) == relationship
    end

    test "create_relationship/1 with valid data creates a relationship" do
      assert {:ok, %Relationship{} = relationship} = Core.create_relationship(@valid_attrs)
    end

    test "create_relationship/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_relationship(@invalid_attrs)
    end

    test "update_relationship/2 with valid data updates the relationship" do
      relationship = relationship_fixture()
      assert {:ok, %Relationship{} = relationship} = Core.update_relationship(relationship, @update_attrs)
    end

    test "update_relationship/2 with invalid data returns error changeset" do
      relationship = relationship_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_relationship(relationship, @invalid_attrs)
      assert relationship == Core.get_relationship!(relationship.id)
    end

    test "delete_relationship/1 deletes the relationship" do
      relationship = relationship_fixture()
      assert {:ok, %Relationship{}} = Core.delete_relationship(relationship)
      assert_raise Ecto.NoResultsError, fn -> Core.get_relationship!(relationship.id) end
    end

    test "change_relationship/1 returns a relationship changeset" do
      relationship = relationship_fixture()
      assert %Ecto.Changeset{} = Core.change_relationship(relationship)
    end
  end
end
