defmodule Raffley.Admin.Charities do
  use Raffley, :query

  alias Raffley.Charities.Charity

  def charities_name_and_ids do
    Charity
    |> order_by(:name)
    |> select([c], {c.name, c.id})
    |> Repo.all()
  end
end
