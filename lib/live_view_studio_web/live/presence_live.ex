defmodule LiveViewStudioWeb.PresenceLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudioWeb.Presence

  @topic "users:video"

  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      Presence.subscribe(@topic)

      {:ok, _} = Presence.track_user(current_user, @topic, %{is_playing: false})
    end

    presences = Presence.list_users(@topic)

    socket =
      socket
      |> assign(:is_playing, false)
      |> assign(:presences, Presence.simple_presence_map(presences))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="presence">
      <div class="users">
        <h2>
          Who's Here?
          <button phx-click={toggle_presences()}>
            <.icon name="hero-list-bullet-solid" />
          </button>
        </h2>
        <ul id="presences">
          <li :for={{_user_id, meta} <- @presences}>
            <span class="status">
              <%= if meta.is_playing, do: "👀", else: "🙈" %>
            </span>
            <span class="username">
              <%= meta.username %>
            </span>
          </li>
        </ul>
      </div>
      <div class="video" phx-click="toggle-playing">
        <%= if @is_playing do %>
          <.icon name="hero-pause-circle-solid" />
        <% else %>
          <.icon name="hero-play-circle-solid" />
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("toggle-playing", _, socket) do
    socket = update(socket, :is_playing, fn playing -> !playing end)

    %{current_user: current_user} = socket.assigns

    Presence.update_user(current_user, @topic, %{is_playing: socket.assigns.is_playing})

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    {:noreply, Presence.handle_diff(socket, diff)}
  end

  def toggle_presences(js \\ %JS{}) do
    js
    |> JS.toggle(to: "#presences")
    |> JS.remove_class(
      "bg-slate-400",
      to: ".hero-list-bullet-solid.bg-slate-400"
    )
    |> JS.add_class(
      "bg-slate-400",
      to: ".hero-list-bullet-solid:not(.bg-slate-400)"
    )
  end
end
