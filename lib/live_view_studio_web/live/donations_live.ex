defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    socket =
      assign(
        socket,
        sort_by_links: ~w(item quantity days_until_expires)a
      )

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    sort_by = (params["sort_by"] || "id") |> String.to_atom()
    sort_order = (params["sort_order"] || "asc") |> String.to_atom() |> next_sort_order()

    options = %{
      sort_by: sort_by,
      sort_order: sort_order
    }

    donations = Donations.list_donations(options)

    socket =
      assign(socket,
        donations: donations,
        options: options
      )

    {:noreply, socket}
  end

  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true

  def sort_link_th(assigns) do
    ~H"""
    <th class={[@sort_by == :item && "item"]}>
      <.link patch={
        ~p"/donations?#{%{sort_by: @sort_by, sort_order: @options.sort_order}}"
      }>
        <%= render_slot(@inner_block) %>
      </.link>
    </th>
    """
  end

  defp next_sort_order(:asc), do: :desc
  defp next_sort_order(:desc), do: :asc
end
