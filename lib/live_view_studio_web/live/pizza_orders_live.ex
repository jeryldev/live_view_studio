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

    page = param_to_integer(params["page"], 1)
    per_page = param_to_integer(params["per_page"], 5)

    options = %{
      sort_by: sort_by,
      sort_order: sort_order,
      page: page,
      per_page: per_page
    }

    pizza_orders = PizzaOrders.list_pizza_orders(options)
    pizza_order_count = PizzaOrders.pizza_order_count()

    socket =
      assign(socket,
        pizza_orders: pizza_orders,
        options: options,
        pizza_order_count: pizza_order_count
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

  defp param_to_integer(nil, default), do: default

  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {value, ""} -> value
      _ -> default
    end
  end

  defp pages(options, pizza_order_count) do
    page_count = ceil(pizza_order_count / options.per_page)

    for page_number <- (options.page - 2)..(options.page + 2), page_number > 0 do
      if page_number <= page_count do
        current_page? = page_number == options.page
        {page_number, current_page?}
      end
    end
  end
end
