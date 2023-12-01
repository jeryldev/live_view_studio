defmodule LiveViewStudioWeb.PizzaOrdersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.PizzaOrders
  import Number.Currency

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        sort_by_links: ~w(id size style topping_1 topping_2 price)a
      )

    {:ok, socket, temporary_assigns: [pizza_orders: []]}
  end

  def handle_params(params, _uri, socket) do
    sort_by = valid_sort_by(params)
    sort_order = valid_sort_order(params)

    options = %{
      sort_by: sort_by,
      sort_order: sort_order
    }

    pizza_orders = PizzaOrders.list_pizza_orders(options)

    socket =
      assign(socket,
        pizza_orders: pizza_orders,
        options: options
      )

    {:noreply, socket}
  end

  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true

  def sort_link_th(assigns) do
    ~H"""
    <th class={[@sort_by == :id && "id"]}>
      <.link patch={
        ~p"/pizza-orders?#{%{sort_by: @sort_by, sort_order: @options.sort_order}}"
      }>
        <%= render_slot(@inner_block) %>
        <%= sort_indicator(@sort_by, @options) %>
      </.link>
    </th>
    """
  end

  def header_map(column) do
    %{
      id: "#",
      size: "Size",
      style: "Style",
      topping_1: "Topping 1",
      topping_2: "Topping 2",
      price: "Price"
    }[column]
  end

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(id size style topping_1 topping_2 price) do
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
end
