defmodule Raffley.Admin.Raffles do
  use Raffley, :query

  alias Raffley.Raffles.Raffle

  def list_raffles do
    Raffle
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def get_raffle!(id), do: Repo.get!(Raffle, id)

  def fetch_raffle(id), do: fetch(id, &get_raffle!/1)

  def create_raffle(attrs) do
    %Raffle{}
    |> Raffle.changeset(attrs)
    |> Repo.insert()
  end

  def change_raffle(%Raffle{} = raffle, attrs \\ %{}) do
    Raffle.changeset(raffle, attrs)
  end

  def update_raffle(%Raffle{} = raffle, attrs) do
    raffle
    |> Raffle.changeset(attrs)
    |> Repo.update()
  end

  def delete_raffle(raffle) do
    Repo.delete(raffle)
  end

  defp fetch(attr, f) do
    f.(attr) |> then(&{:ok, &1})
  rescue
    Ecto.NoResultsError -> {:error, :not_found}
  end
end
