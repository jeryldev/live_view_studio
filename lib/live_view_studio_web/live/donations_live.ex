defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    socket =
      assign(
        socket,
        sort_by_links: ~w(item quantity days_until_expires)a
      )

    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _uri, socket) do
    sort_by = valid_sort_by(params)
    sort_order = valid_sort_order(params)
    page = params_to_integer(params["page"], 1)
    per_page = params_to_integer(params["per_page"], 5)

    options = %{
      sort_by: sort_by,
      sort_order: sort_order,
      page: page,
      per_page: per_page
    }

    donations = Donations.list_donations(options)

    socket =
      assign(socket,
        donations: donations,
        options: options
      )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}
    socket = push_patch(socket, to: ~p"/donations?#{params}")
    {:noreply, socket}
  end

  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true

  def sort_link_th(assigns) do
    params = %{assigns.options | sort_by: assigns.sort_by, sort_order: assigns.options.sort_order}
    assigns = assign(assigns, params: params)

    ~H"""
    <th class={[@sort_by == :item && "item"]}>
      <.link patch={~p"/donations?#{@params}"}>
        <%= render_slot(@inner_block) %>
        <%= sort_indicator(@sort_by, @options) %>
      </.link>
    </th>
    """
  end

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(item quantity days_until_expires) do
    String.to_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id

  defp valid_sort_order(%{"sort_order" => sort_order})
       when sort_order in ~w(asc desc) do
    next_sort_order(sort_order)
  end

  defp valid_sort_order(_params), do: :asc

  defp next_sort_order("asc"), do: :desc
  defp next_sort_order("desc"), do: :asc
  defp next_sort_order(_sort_order), do: :asc

  defp sort_indicator(column, %{sort_by: sort_by, sort_order: sort_order})
       when column == sort_by do
    case sort_order do
      :asc -> "👆"
      :desc -> "👇"
    end
  end

  defp sort_indicator(_column, _options), do: ""

  defp params_to_integer(nil, default), do: default

  defp params_to_integer(value, default) do
    case Integer.parse(value) do
      {integer, ""} -> integer
      _ -> default
    end
  end
end
