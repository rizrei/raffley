defmodule RaffleyWeb.Api.RaffleJSON do
  alias Raffley.Raffles.Raffle

  def index(%{raffles: raffles}) do
    %{
      raffles: raffles |> Enum.map(&raffle_attrs/1)
    }
  end

  def show(%{raffle: raffle}) do
    %{
      raffle: raffle_attrs(raffle)
    }
  end

  @raffle_attributes [:id, :prize, :description, :ticket_price, :status, :image_path, :charity_id]
  defp raffle_attrs(%Raffle{} = raffle) do
    raffle
    |> Map.take(@raffle_attributes)
  end
end
