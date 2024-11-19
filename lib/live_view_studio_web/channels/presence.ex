defmodule LiveViewStudioWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :live_view_studio,
    pubsub_server: LiveViewStudio.PubSub

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(LiveViewStudio.PubSub, topic)
  end

  def track_user(user, topic, meta \\ %{}) do
    default_meta = %{username: user.email |> String.split("@") |> hd()}

    track(self(), topic, user.id, Map.merge(default_meta, meta))
  end

  def list_users(topic) do
    list(topic)
  end

  def simple_presence_map(presences) do
    Enum.into(presences, %{}, fn {user_id, %{metas: [meta | _]}} -> {user_id, meta} end)
  end

  def update_user(user, topic, new_meta) do
    %{metas: [meta | _]} = get_by_key(topic, user.id)

    update(self(), topic, user.id, Map.merge(meta, new_meta))
  end

  def handle_diff(socket, diff) do
    socket
    |> remove_presences(diff.leaves)
    |> add_presences(diff.joins)
  end

  defp add_presences(socket, joins) do
    joins
    |> simple_presence_map()
    |> Enum.reduce(socket, fn {user_id, meta}, socket ->
      Phoenix.Component.update(socket, :presences, &Map.put(&1, user_id, meta))
    end)
  end

  defp remove_presences(socket, leaves) do
    leaves
    |> simple_presence_map()
    |> Enum.reduce(socket, fn {user_id, _}, socket ->
      Phoenix.Component.update(socket, :presences, &Map.delete(&1, user_id))
    end)
  end
end
