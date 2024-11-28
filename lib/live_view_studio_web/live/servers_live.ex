defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers

  def mount(_params, _session, socket) do
    # IO.inspect(self(), label: "MOUNT")

    if connected?(socket) do
      Servers.subscribe()
    end

    servers = Servers.list_servers()

    socket =
      assign(socket,
        servers: servers,
        coffees: 0
      )

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    # IO.inspect(self(), label: "HANDLE PARAMS ID #{id}")
    server = Servers.get_server!(id)
    {:noreply, assign(socket, selected_server: server, page_title: "What's up #{server.name}?")}
  end

  def handle_params(_params, _uri, socket) do
    # IO.inspect(self(), label: "HANDLE PARAMS CATCH-ALL")

    socket =
      if socket.assigns.live_action == :new,
        do: assign(socket, selected_server: nil),
        else: assign(socket, selected_server: hd(socket.assigns.servers))

    {:noreply, socket}
  end

  def render(assigns) do
    # IO.inspect(self(), label: "RENDER")

    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link patch={~p"/servers/new"} class="add">
            + Add New Server
          </.link>
          <.server
            :for={server <- @servers}
            server={server}
            selected_server={@selected_server}
          />
        </div>
        <%!-- <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div> --%>
      </div>
      <div class="main">
        <div class="wrapper">
          <%= if @live_action == :new do %>
            <.live_component
              module={LiveViewStudioWeb.ServerFormComponent}
              id={:new}
            />
          <% else %>
            <.selected_server server={@selected_server} />
          <% end %>
          <div class="links">
            <.link navigate={~p"/topsecret"}>
              Top Secret
            </.link>
            <.link navigate={~p"/light"}>
              Adjust lights
            </.link>
            <a
              id={"#{@selected_server.id}-clipboard"}
              data-content={
                url(@socket, ~p"/servers/?id=#{@selected_server}")
              }
              phx-hook="Clipboard"
            >
              Copy Link
            </a>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def server(assigns) do
    ~H"""
    <.link
      patch={~p"/servers/#{@server}"}
      class={if @server == @selected_server, do: "selected"}
    >
      <span class={@server.status}></span>
      <%= @server.name %>
    </.link>
    """
  end

  def selected_server(assigns) do
    ~H"""
    <div class="server">
      <div class="header">
        <h2><%= @server.name %></h2>
        <button
          class={@server.status}
          phx-click="toggle-status"
          phx-value-id={@server.id}
        >
          <%= @server.status %>
        </button>
      </div>
      <div class="body">
        <div class="row">
          <span>
            <%= @server.deploy_count %> deploys
          </span>
          <span>
            <%= @server.size %> MB
          </span>
          <span>
            <%= @server.framework %>
          </span>
        </div>
        <h3>Last Commit Message:</h3>
        <blockquote>
          <%= @server.last_commit_message %>
        </blockquote>
      </div>
    </div>
    """
  end

  def handle_info({:server_created, server}, socket) do
    {:noreply,
     socket
     |> update(:servers, fn servers -> [server | servers] end)
     |> push_patch(to: ~p"/servers/#{server}")}
  end

  def handle_info({:server_updated, server}, socket) do
    socket =
      if server.id == socket.assigns.selected_server.id do
        assign(socket, selected_server: server)
      else
        socket
      end

    # socket = assign(socket,servers: Servers.list_servers())
    # servers =
    #   Enum.map(socket.assigns.servers, fn s ->
    #     if s.id == server.id, do: server, else: s
    #   end)

    # socket = assign(socket, servers: servers)

    socket =
      update(socket, :servers, fn servers ->
        for s <- servers do
          if s.id == server.id, do: server, else: s
        end
      end)

    {:noreply, socket}
  end

  def handle_event("drink", _, socket) do
    # IO.inspect(self(), label: "HANDLE EVENT DRINK")
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    server = Servers.get_server!(id)

    new_status = if server.status == "up", do: "down", else: "up"

    {:ok, _server} = Servers.update_server(server, %{status: new_status})

    {:noreply, socket}
  end
end
