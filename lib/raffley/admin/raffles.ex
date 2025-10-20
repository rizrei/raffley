defmodule Raffley.Admin.Raffles do
  use Raffley, :query

  alias Raffley.Raffles.Raffle

  def list_raffles do
    Raffle
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
