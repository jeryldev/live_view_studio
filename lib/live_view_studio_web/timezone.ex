defmodule LiveViewStudioWeb.Timezone do
  use LiveViewStudioWeb, :live_view

  def on_mount(:timezone, _params, _session, socket) do
    if connected?(socket) do
      %{"timezone" => tz} = get_connect_params(socket)
      {:cont, assign(socket, :timezone, tz)}
    else
      {:cont, socket}
    end
  end
end
