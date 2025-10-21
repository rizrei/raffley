defmodule Raffley.Queries.Raffles.FilterRaffles do
  @moduledoc """
  Builds and executes a filtered query for `Raffle` records.

  Supported params:
    * `"status"` - one of: "open", "closed", "upcoming"
    * `"charity"` - charity slug
    * `"q"` - case-insensitive search in prize name
    * `"sort_by"` - one of: "prize", "ticket_price_asc", "ticket_price_desc", "charity"
  """

  use Raffley, :query

  alias Raffley.Raffles.Raffle

  def call(params) do
    Raffle
    |> with_status(params["status"])
    |> with_charity(params["charity"])
    |> search_by(params["q"])
    |> sort(params["sort_by"])
    |> Repo.all()
  end

  @status_values ~w(open closed upcoming)
  defp with_status(query, status) when status in @status_values,
    do: where(query, status: ^status)

  defp with_status(query, _), do: query

  defp search_by(query, ""), do: query
  defp search_by(query, q) when is_binary(q), do: where(query, [r], ilike(r.prize, ^"%#{q}%"))
  defp search_by(query, _), do: query

  defp sort(query, "prize"), do: order_by(query, :prize)
  defp sort(query, "ticket_price_desc"), do: order_by(query, desc: :ticket_price)
  defp sort(query, "ticket_price_asc"), do: order_by(query, :ticket_price)

  defp sort(query, "charity") do
    query
    |> join_charity()
    |> order_by([_r, c], c.name)
  end

  defp sort(query, _), do: query

  defp with_charity(query, slug) when slug in ["", nil], do: query

  defp with_charity(query, slug) do
    query
    |> join_charity()
    |> where([_r, c], c.slug == ^slug)
  end

  defp join_charity(query) when is_named_binding(query, :charity) == true, do: query
  defp join_charity(query), do: join(query, :inner, [r], c in assoc(r, :charity))
end
