defmodule RaffleyWeb.RuleController do
  use RaffleyWeb, :controller
  alias Raffley.Rules

  def index(conn, _params) do
    rules = Rules.list_rules()
    emojis = ~w(🏆 🙌 🎉) |> Enum.random() |> String.duplicate(5)
    render(conn, :index, rules: rules, emojis: emojis)
  end
end
