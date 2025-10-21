defmodule Raffley.Raffles do
  use Raffley, :query

  alias Raffley.Raffles.Raffle
  alias Raffley.Queries.Raffles.FilterRaffles

  def list_raffles() do
    Repo.all(Raffle)
  end

  def filter_raffles(filters \\ %{}) do
    FilterRaffles.call(filters) |> Repo.preload(:charity)
  end

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
  end

  def get_raffle_with_charity!(id) do
    id |> get_raffle!() |> Repo.preload(:charity)
  end

  def featured_raffles(raffle) do
    Process.sleep(:timer.seconds(2))

    Raffle
    |> where(status: :open)
    |> where([r], r.id != ^raffle.id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end
end
