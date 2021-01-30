defmodule Erflow.LiveUpdates do

  @doc "subscribe for all users"
  def subscribe_live_view(topic) do
    Phoenix.PubSub.subscribe(Erflow.PubSub, get_topic(topic), link: true)
  end

  @doc "subscribe for specific user"
  def subscribe_live_view(topic, user_id) do
    Phoenix.PubSub.subscribe(Erflow.PubSub, get_topic(topic, user_id), link: true)
  end

  @doc "notify for all users"
  def notify_live_view(topic, message) do
    Phoenix.PubSub.broadcast(Erflow.PubSub, get_topic(topic), message)
  end

  @doc "notify for specific user"
  def notify_live_view(topic, user_id, message) do
    Phoenix.PubSub.broadcast(Erflow.PubSub, get_topic(topic, user_id), message)
  end

  defp get_topic(topic), do: topic
  defp get_topic(topic, user_id), do: get_topic(topic) <> to_string(user_id)
end
