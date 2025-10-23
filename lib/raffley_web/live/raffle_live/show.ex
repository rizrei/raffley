defmodule RaffleyWeb.RaffleLive.Show do
  use RaffleyWeb, :live_view

  alias Raffley.Raffles
  alias Raffley.Tickets
  alias Raffley.Tickets.Ticket
  alias Phoenix.LiveView.AsyncResult

  import RaffleyWeb.BadgeComponents

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="raffle-show">
        <div class="raffle">
          <img src={@raffle.image_path} />
          <section>
            <.badge status={@raffle.status} />
            <header>
              <div>
                <h2>{@raffle.prize}</h2>
                <h3>{@raffle.charity.name}</h3>
              </div>
              <div>
                <h2>{@raffle.prize}</h2>
                <.link :if={@raffle.charity} navigate={~p"/charities/#{@raffle.charity}"}>
                  <h3>{@raffle.charity.name}</h3>
                </.link>
              </div>

              <div class="price">
                ${@raffle.ticket_price} / ticket
              </div>
            </header>
            <div class="totals">
              {@ticket_count} Tickets Sold &bull; ${@ticket_sum} Raised
            </div>
            <div class="description">
              {@raffle.description}
            </div>
          </section>
        </div>
        <div class="activity">
          <div class="left">
            <div :if={@raffle.status == :open}>
              <%= if @current_scope do %>
                <.form for={@form} id="ticket-form" phx-change="validate" phx-submit="save">
                  <.input field={@form[:comment]} placeholder="Comment..." autofocus />
                  <.button>
                    Get A Ticket
                  </.button>
                </.form>
              <% else %>
                <.button navigate={~p"/users/log-in"}>
                  Log In To Get A Ticket
                </.button>
              <% end %>
            </div>

            <div id="tickets" phx-update="stream">
              <.ticket :for={{dom_id, ticket} <- @streams.tickets} ticket={ticket} id={dom_id} />
            </div>
          </div>
          <div class="right">
            <.featured_raffles raffles={@featured_raffles} />
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def featured_raffles(assigns) do
    ~H"""
    <section>
      <h4>Featured Raffles</h4>
      <.async_result :let={result} assign={@raffles}>
        <:loading>
          <div class="loading">
            <div class="spinner"></div>
          </div>
        </:loading>
        <:failed :let={{:error, reason}}>
          <div class="failed">
            Yikes: {reason}
          </div>
        </:failed>
        <ul class="raffles">
          <li :for={raffle <- result}>
            <.link navigate={~p"/raffles/#{raffle}"}>
              <img src={raffle.image_path} /> {raffle.prize}
            </.link>
          </li>
        </ul>
      </.async_result>
    </section>
    """
  end

  attr :id, :string, required: true
  attr :ticket, Ticket, required: true

  def ticket(assigns) do
    ~H"""
    <div class="ticket" id={@id}>
      <span class="timeline"></span>
      <section>
        <div class="price-paid">
          ${@ticket.price}
        </div>
        <div>
          <span class="name">
            {@ticket.user.name}
          </span>
          bought a ticket
          <blockquote>
            {@ticket.comment}
          </blockquote>
        </div>
      </section>
    </div>
    """
  end

  on_mount {RaffleyWeb.UserAuth, :mount_current_scope}

  def mount(%{"id" => id}, _session, socket) do
    raffle = Raffles.get_raffle_with_charity!(id)
    tickets = Tickets.list_tickets_by_raffle(raffle)

    socket =
      socket
      |> assign(form: ticket_form(socket.assigns))
      |> assign(:raffle, raffle)
      |> stream(:tickets, tickets)
      |> assign(:ticket_count, Enum.count(tickets))
      |> assign(:ticket_sum, Enum.sum_by(tickets, & &1.price))
      |> assign(:page_title, raffle.prize)
      |> assign(:featured_raffles, AsyncResult.loading())
      |> start_async(:fetch_raffles_task, fn -> Raffles.featured_raffles(raffle) end)

    {:ok, socket}
  end

  def handle_async(:fetch_raffles_task, {:ok, raffles}, socket) do
    # do anything extra here

    result = AsyncResult.ok(socket.assigns.featured_raffles, raffles)

    {:noreply, assign(socket, :featured_raffles, result)}
  end

  def handle_async(:fetch_raffles_task, {:exit, reason}, socket) do
    # do anything extra

    result = AsyncResult.failed(socket.assigns.featured_raffles, {:exit, reason})

    {:noreply, assign(socket, :featured_raffles, result)}
  end

  def handle_event("validate", %{"ticket" => ticket_params}, socket) do
    form =
      socket.assigns.current_scope
      |> Tickets.change_ticket(%Ticket{}, ticket_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"ticket" => ticket_params}, socket) do
    case create_ticket(socket.assigns, ticket_params) do
      {:ok, ticket} ->
        {:noreply,
         socket
         |> stream_insert(:tickets, ticket, at: 0)
         |> update(:ticket_sum, &(&1 + ticket.price))
         |> update(:ticket_count, &(&1 + 1))
         |> assign(form: ticket_form(socket.assigns))
         |> put_flash(:info, "Ticket created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def ticket_form(%{current_scope: scope}) do
    Tickets.change_ticket(scope, %Ticket{}) |> to_form()
  end

  def create_ticket(%{raffle: raffle, current_scope: scope}, params) do
    params = params |> Map.merge(%{"raffle_id" => raffle.id, "price" => raffle.ticket_price})
    Tickets.create_ticket(scope, params)
  end
end
