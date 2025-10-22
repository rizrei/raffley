defmodule RaffleyWeb.Api.RaffleController do
  use RaffleyWeb, :controller

  alias Raffley.Admin.Raffles

  action_fallback RaffleyWeb.FallbackController

  def index(conn, _params) do
    conn
    |> assign(:raffles, Raffles.list_raffles())
    |> render(:index)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, raffle} <- Raffles.fetch_raffle(id) do
      conn
      |> assign(:raffle, raffle)
      |> render(:show)
    end
  end

  def create(conn, %{"raffle" => raffle_params}) do
    with {:ok, raffle} <- Raffles.create_raffle(raffle_params) do
      conn
      |> assign(:raffle, raffle)
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/raffles/#{raffle}")
      |> render(:show)
    end
  end
end
