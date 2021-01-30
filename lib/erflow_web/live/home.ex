defmodule ErflowWeb.Home do
  use Phoenix.LiveView

  @impl true
  def mount(_params, _session, socket) do
    Erflow.LiveUpdates.subscribe_live_view("state")
    {:ok, assign(socket, :dags, initial_state())}
  end

  defp initial_state() do
    [%{name: "A", state: "red-dot"}, %{name: "B", state: "gray-dot"}]
  end

  @impl true
  def handle_info(:update, socket) do
    {:noreply, assign(socket, :dags, update_state("red-dot"))}
  end

  def handle_info({"state", [:dags, :updated], [new_state]}, socket) do
    {:noreply, assign(socket, :dags, update_state(new_state))}
  end

  @impl true
  def handle_event("start", _, socket) do
    #send(self(), :update)
    new_state = Enum.random(["green-dot", "red-dot", "gray-dot"])
    Erflow.LiveUpdates.notify_live_view("state", {"state", [:dags, :updated], [new_state]})
    {:noreply, socket}
  end

  defp update_state(new_state) do
    [%{name: "A", state: new_state}, %{name: "B", state: new_state}]
  end

end
