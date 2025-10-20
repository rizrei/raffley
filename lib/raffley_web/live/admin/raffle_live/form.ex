defmodule RaffleyWeb.Admin.RaffleLive.Form do
  use RaffleyWeb, :live_view

  alias Raffley.Admin.Raffles
  alias Raffley.Raffles.Raffle

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {
      :noreply,
      socket
      |> assign(:page_title, "New Raffle")
      |> assign(:form, %Raffle{} |> Raffles.change_raffle() |> to_form())
    }
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>{@page_title}</.header>

      <.form for={@form} id="raffle-form" phx-submit="save" phx-change="validate">
        <.input field={@form[:prize]} label="Prize" required="true" />

        <.input
          field={@form[:description]}
          type="textarea"
          label="Description"
          required="true"
          phx-debounce="500"
        />

        <.input
          field={@form[:ticket_price]}
          type="number"
          label="Ticket price"
          required="true"
          phx-debounce="500"
        />

        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          prompt="Choose a status"
          options={[:upcoming, :open, :closed]}
          required="true"
        />

        <.input field={@form[:image_path]} label="Image Path" required="true" />

        <.button phx-disable-with="Saving...">Save Raffle</.button>
      </.form>

      <.button navigate={~p"/admin/raffles"}>Back</.button>
    </Layouts.app>
    """
  end

  def handle_event("validate", %{"raffle" => raffle_params}, socket) do
    form = %Raffle{} |> Raffles.change_raffle(raffle_params) |> to_form(action: :validate)

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"raffle" => raffle_params}, socket) do
    socket =
      case Raffles.create_raffle(raffle_params) do
        {:ok, _raffle} ->
          socket
          |> put_flash(:info, "Raffle created successfully!")
          |> push_navigate(to: ~p"/admin/raffles")

        {:error, %Ecto.Changeset{} = changeset} ->
          socket
          |> assign(:form, to_form(changeset))
      end

    {:noreply, socket}
  end
end
