defmodule RaffleyWeb.RuleController do
  use RaffleyWeb, :controller
  alias Raffley.Rules

  def index(conn, _params) do
    conn
    |> assign(:rules, Rules.list_rules())
    |> assign(:emojis, ~w(🏆 🙌 🎉) |> Enum.random() |> String.duplicate(5))
    |> render(:index)
  end

  def show(conn, %{"id" => id}) do
    conn
    |> assign(:rule, Rules.get_rule(id))
    |> assign(:greating, ~w(Hi Howdy Hello) |> Enum.random())
    |> render(:show)
  end
end
