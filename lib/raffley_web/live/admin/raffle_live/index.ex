defmodule RaffleyWeb.Admin.RaffleLive.Index do
  use RaffleyWeb, :live_view

  alias Raffley.Admin.Raffles
  import RaffleyWeb.BadgeComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    socket =
      socket
      |> assign(:page_title, "Listing Raffles")
      |> stream(:raffles, Raffles.list_raffles())

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    socket =
      case Raffles.get_raffle!(id) |> Raffles.delete_raffle() do
        {:ok, raffle} ->
          socket
          |> put_flash(:info, "Raffle deleted successfully!")
          |> stream_delete(:raffles, raffle)

        {:error, %Ecto.Changeset{}} ->
          socket
          |> put_flash(:error, "Something went wrong!")
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="admin-index">
        <.header>
          {@page_title}
          <:actions>
            <.button navigate={~p"/admin/raffles/new"}>New Raffle</.button>
          </:actions>
        </.header>

        <.table id="raffles" rows={@streams.raffles}>
          <:col :let={{_dom_id, raffle}} label="Prize">
            <.link navigate={~p"/raffles/#{raffle}"}>
              {raffle.prize}
            </.link>
          </:col>
          <:col :let={{_dom_id, raffle}} label="Status">
            <.badge status={raffle.status} />
          </:col>
          <:col :let={{_dom_id, raffle}} label="Ticket Price">
            {raffle.ticket_price}
          </:col>

          <:action :let={{_dom_id, raffle}}>
            <.link navigate={~p"/admin/raffles/#{raffle}/edit"}>Edit</.link>
          </:action>

          <:action :let={{_dom_id, raffle}}>
            <.link phx-click="delete" phx-value-id={raffle.id} data-confirm="Are you shure?">
              Delete
            </.link>
          </:action>
        </.table>
      </div>
    </Layouts.app>
    """
  end
end
