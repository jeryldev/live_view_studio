defmodule LiveViewStudioWeb.SandboxLive do
  use LiveViewStudioWeb, :live_view

  import Number.Currency
  alias LiveViewStudio.Sandbox

  def mount(_params, _session, socket) do
    socket = assign(socket, length: "0", width: "0", depth: "0", weight: 0.0, price: nil)
    {:ok, socket}
  end

  def handle_event("calculate", params, socket) do
    %{"length" => l, "width" => w, "depth" => d} = params
    weight = Sandbox.calculate_weight(l, w, d)
    socket = assign(socket, length: l, width: w, depth: d, weight: weight, price: nil)
    {:noreply, socket}
  end

  def handle_event("get-quote", _, socket) do
    price = Sandbox.calculate_price(socket.assigns.weight)
    socket = assign(socket, price: price)
    {:noreply, socket}
  end
end
