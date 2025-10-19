defmodule Raffley.Raffles do
  use Raffley, :query

  alias Raffley.Raffles.Raffle
  alias Raffley.Queries.Raffles.FilterRaffles

  def list_raffles() do
    Repo.all(Raffle)
  end

  def filter_raffles(filters \\ %{}) do
    FilterRaffles.call(filters)
  end

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
  end

  def featured_raffles(raffle) do
    Raffle
    |> where(status: :open)
    |> where([r], r.id != ^raffle.id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end
end
