defmodule Raffley.RafflesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Raffley.Raffles` context.
  """

  @doc """
  Generate a raffle.
  """
  def raffle_fixture(attrs \\ %{}) do
    {:ok, ticket} =
      attrs |> Enum.into(raffle_default_attributes()) |> Raffley.Raffles.create_raffle()

    ticket
  end

  defp raffle_default_attributes do
    %{
      prize: "prize",
      description: "description"
    }
  end
end
