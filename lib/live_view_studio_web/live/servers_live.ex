defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_params, _session, socket) do
    # IO.inspect(self(), label: "MOUNT")
    servers = Servers.list_servers()

    changeset = Servers.change_server(%Server{})

    socket =
      assign(socket,
        servers: servers,
        coffees: 0,
        form: to_form(changeset)
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
    {:noreply, assign(socket, :selected_server, hd(socket.assigns.servers))}
  end

  def render(assigns) do
    # IO.inspect(self(), label: "RENDER")

    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.server
            :for={server <- @servers}
            server={server}
            selected_server={@selected_server}
          />
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <.form for={@form} phx-submit="save">
            <div class="field">
              <.input field={@form[:name]} placeholder="Name" />
            </div>
            <div class="field">
              <.input field={@form[:framework]} placeholder="Framework" />
            </div>
            <div class="field">
              <.input
                field={@form[:size]}
                placeholder="Size (MB)"
                type="number"
              />
            </div>
            <.button phx-disable-with="Saving...">
              Save
            </.button>
          </.form>

          <.selected_server server={@selected_server} />
          <div class="links">
            <.link navigate={~p"/light"}>
              Adjust lights
            </.link>
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
        <span class={@server.status}>
          <%= @server.status %>
        </span>
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

  def handle_event("drink", _, socket) do
    # IO.inspect(self(), label: "HANDLE EVENT DRINK")
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        socket = update(socket, :servers, fn servers -> [server | servers] end)

        changeset = Servers.change_server(%Server{})

        {:noreply, assign(socket, :form, to_form(changeset))}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
