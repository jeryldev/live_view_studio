defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Volunteers.subscribe()
    end

    volunteers = Volunteers.list_volunteers()

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:count, length(volunteers))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.live_component
        module={LiveViewStudioWeb.VolunteerFormComponent}
        id={:new}
        count={@count}
      />
      <pre>
        <%#= inspect(@form, pretty: true) %>
      </pre>
      <div id="volunteers" phx-update="stream">
        <.volunteer
          :for={{volunteer_dom_id, volunteer} <- @streams.volunteers}
          id={volunteer_dom_id}
          volunteer={volunteer}
        />
      </div>
    </div>
    """
  end

  def volunteer(assigns) do
    ~H"""
    <div
      class={"volunteer #{if @volunteer.checked_out, do: "out"}"}
      id={@id}
    >
      <div class="name">
        <%= @volunteer.name %>
      </div>
      <div class="phone">
        <%= @volunteer.phone %>
      </div>
      <div class="status">
        <button phx-click={
          JS.push("toggle-status",
            value: %{id: @volunteer.id}
          )
          |> JS.transition("shake", to: "##{@id}", time: 500)
        }>
          <%= if @volunteer.checked_out,
            do: "Check In",
            else: "Check Out" %>
        </button>
      </div>
      <.link
        class="delete"
        phx-click={
          JS.push("delete", value: %{id: @volunteer.id})
          |> JS.hide(
            to: "##{@id}",
            transition: "ease duration-1000 scale-150"
          )
        }
        data-confirm="Are you sure?"
      >
        <.icon name="hero-trash-solid" />
      </.link>
    </div>
    """
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    {:noreply,
     socket
     |> stream_insert(:volunteers, volunteer, at: 0)
     |> update(:count, &(&1 + 1))}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    {:noreply, stream_insert(socket, :volunteers, volunteer)}
  end

  def handle_info({:volunteer_deleted, volunteer}, socket) do
    {:noreply,
     socket
     |> stream_delete(:volunteers, volunteer)
     |> update(:count, &(&1 - 1))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, _} = Volunteers.delete_volunteer(volunteer)

    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, _volunteer} = Volunteers.toggle_status_volunteer(volunteer)

    {:noreply, socket}
  end
end
