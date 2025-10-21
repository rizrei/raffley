defmodule RaffleyWeb.CharityLive.Show do
  use RaffleyWeb, :live_view

  alias Raffley.Charities

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Charity {@charity.id}
        <:subtitle>This is a charity record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/charities"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/charities/#{@charity}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit charity
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@charity.name}</:item>
        <:item title="Slug">{@charity.slug}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Charity")
     |> assign(:charity, Charities.get_charity!(id))}
  end
end
