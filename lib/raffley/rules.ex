defmodule Raffley.Rules do
  @moduledoc """
  Module for managing raffle rules.
  """

  @type rule :: %{id: integer(), text: String.t()}

  @spec list_rules() :: list(rule())
  def list_rules do
    [
      %{
        id: 1,
        text: "Participants must have a high tolerance for puns and dad jokes. 🙃"
      },
      %{
        id: 2,
        text: "Winner must do a victory dance when claiming their prize. 🕺"
      },
      %{
        id: 3,
        text: "Have fun! 🎟️"
      }
    ]
  end

  @spec get_rule(integer() | String.t()) :: rule() | nil
  def get_rule(id) when is_integer(id) do
    list_rules() |> Enum.find(&(&1.id == id))
  end

  def get_rule(id) when is_binary(id) do
    id |> String.to_integer() |> get_rule()
  end
end
