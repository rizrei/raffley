defmodule RaffleyWeb.EstimatorLive do
  use RaffleyWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, tickets: 0, price: 3)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="estimator">
        <h1>Raffle Estimator</h1>

        <section>
          <button phx-click="add" phx-value-quantity="5">
            +
          </button>
          <div>{@tickets}</div>
          @
          <div>${@price}</div>
          =
          <div>${@tickets * @price}</div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("add", %{"quantity" => quantity}, socket) do
    socket = update(socket, :tickets, &(&1 + String.to_integer(quantity)))

    {:noreply, socket}
  end
end
