defmodule Raffley.Queries.Raffles.FilterRaffles do
  @moduledoc """
  A query module for filtering raffles based on parameters.
  """
  use Raffley, :query

  alias Raffley.Raffles.Raffle

  def call(params) do
    Raffle
    |> with_status(params["status"])
    |> search_by(params["q"])
    |> sort(params["sort_by"])
    |> Repo.all()
  end

  defp with_status(query, status) when status in ~w(open closed upcoming),
    do: where(query, status: ^status)

  defp with_status(query, _), do: query

  defp search_by(query, ""), do: query
  defp search_by(query, q) when is_binary(q), do: where(query, [r], ilike(r.prize, ^"%#{q}%"))
  defp search_by(query, _), do: query

  defp sort(query, "prize"), do: order_by(query, :prize)
  defp sort(query, "ticket_price_desc"), do: order_by(query, desc: :ticket_price)
  defp sort(query, "ticket_price_asc"), do: order_by(query, :ticket_price)
  defp sort(query, _), do: query
end
