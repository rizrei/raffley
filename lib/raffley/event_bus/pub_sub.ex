defmodule Raffley.EventBus.PubSub do
  @moduledoc """
  Centralized PubSub helper for Raffley.
  Handles topic naming, subscriptions, and broadcasting.
  """

  alias Phoenix.PubSub

  @doc """
    Subscribes to scoped notifications about any changes.
  """
  def subscribe(topic, opts \\ []), do: PubSub.subscribe(Raffley.PubSub, topic, opts)
  def unsubscribe(topic), do: PubSub.unsubscribe(Raffley.PubSub, topic)
  def broadcast(topic, message), do: PubSub.broadcast(Raffley.PubSub, topic, message)
end
