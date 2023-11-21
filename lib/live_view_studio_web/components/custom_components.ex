defmodule LiveViewStudioWeb.CustomComponents do
  use Phoenix.Component

  # these attributes and slots only apply to the function component it immediately follows
  attr :expiration, :integer, default: 24
  slot :legal
  slot :inner_block, required: true

  def promo(assigns) do
    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="expiration">
        Deal expires in <%= @expiration %> hour(s)
      </div>
      <div class="legal">
        <%= render_slot(@legal) %>
      </div>
    </div>
    """
  end
end
