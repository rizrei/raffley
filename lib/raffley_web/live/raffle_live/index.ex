defmodule RaffleyWeb.RaffleLive.Index do
  use RaffleyWeb, :live_view

  import RaffleyWeb.BadgeComponents
  import RaffleyWeb.BannerComponents

  alias Raffley.Raffles
  alias Raffley.Charities

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="raffle-index">
        <.banner :if={false}>
          <.icon name="hero-sparkles-solid" /> Mystery Raffle Coming Soon!
          <:details :let={emoji}>To Be Revealed Tomorrow {emoji}</:details>
          <:details>Any guesses?</:details>
        </.banner>
        <.filter_form form={@form} charity_options={@charity_options} />
        <div class="raffles" id="raffles" phx-update="stream">
          <div id="empty" class="no-results only:block hidden">
            No raffles found. Try changing your filters.
          </div>
          <.raffle_card :for={{dom_id, raffle} <- @streams.raffles} raffle={raffle} id={dom_id} />
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :form, :map, required: true
  attr :charity_options, :list, required: true

  def filter_form(assigns) do
    ~H"""
    <.form for={@form} id="filter-form" phx-change="filter">
      <.input
        field={@form["q"]}
        type="search"
        placeholder="Search..."
        autocomplete="off"
        phx-debounce={500}
      />
      <.input
        field={@form["status"]}
        type="select"
        options={[:upcoming, :open, :closed]}
        prompt="Status"
      />

      <.input
        field={@form["charity"]}
        type="select"
        options={@charity_options}
        prompt="Charity"
      />

      <.input
        field={@form["sort_by"]}
        type="select"
        options={[
          Prize: "prize",
          "Price: High to Low": "ticket_price_desc",
          "Price: Low to High": "ticket_price_asc",
          Charity: "charity"
        ]}
        prompt="Sort"
      />
      <.button patch={~p"/raffles"}>
        Reset
      </.button>
    </.form>
    """
  end

  attr :raffle, Raffley.Raffles.Raffle, required: true
  attr :id, :string, required: true

  def raffle_card(assigns) do
    ~H"""
    <.link navigate={~p"/raffles/#{@raffle}"} id={@id}>
      <div class="card">
        <div :if={@raffle.charity} class="charity">
          {@raffle.charity.name}
        </div>
        <img src={@raffle.image_path} />
        <h2>{@raffle.prize}</h2>
        <div class="details">
          <div class="price">
            ${@raffle.ticket_price} / ticket
          </div>
          <.badge status={@raffle.status} />
        </div>
      </div>
    </.link>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:charity_options, Charities.charities_name_and_slugs())

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> stream(:raffles, Raffles.filter_raffles(params), reset: true)
      |> assign(:form, to_form(params))

    {:noreply, socket}
  end

  def handle_event("filter", params, socket) do
    filtered_params =
      params
      |> Map.filter(fn {k, v} -> k in ~w(q status sort_by charity) and v not in [nil, ""] end)

    socket = push_patch(socket, to: ~p"/raffles?#{filtered_params}")

    {:noreply, socket}
  end
end
