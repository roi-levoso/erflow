defmodule Scheduler.DagsWatcherTest do
  use ExUnit.Case, async: true

  defmodule FakeFileSystem do
    def start_link(dirs: [dirs]), do: {:ok, 1}
    def subscribe(watcher_pid), do: :ok
  end

  describe "init/1" do
    test "init succesful" do
    dags_dir = "test/test_dags_folder"
    assert Scheduler.DagsWatcher.init(%{watcher: FileSystem, dags_dir: dags_dir}) == {:ok, Path.absname(dags_dir)}
    end
    test "dags folder does not exist file exists" do
      dags_dir = "wrong/folder"
    assert Scheduler.DagsWatcher.init(%{watcher: FileSystem, dags_dir: dags_dir}) == {:error, "#{dags_dir} does not exist"}
    end

  end
end
