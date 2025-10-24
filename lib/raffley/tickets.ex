defmodule Raffley.Tickets do
  @moduledoc """
  The Tickets context.
  """

  use Raffley, :query
  use Raffley, :pub_sub

  alias Raffley.Raffles.Raffle
  alias Raffley.Tickets.Ticket
  alias Raffley.Accounts.Scope

  @doc """
  Returns the list of tickets.

  ## Examples

      iex> list_tickets(scope)
      [%Ticket{}, ...]

  """
  def list_tickets(%Scope{} = scope) do
    Repo.all_by(Ticket, user_id: scope.user.id)
  end

  def list_tickets_by_raffle(%Raffle{id: raffle_id}) do
    Ticket
    |> order_by(desc: :inserted_at)
    |> Repo.all_by(raffle_id: raffle_id)
    |> Repo.preload([:user])
  end

  @doc """
  Gets a single ticket.

  Raises `Ecto.NoResultsError` if the Ticket does not exist.

  ## Examples

      iex> get_ticket!(scope, 123)
      %Ticket{}

      iex> get_ticket!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_ticket!(%Scope{} = scope, id) do
    Repo.get_by!(Ticket, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a ticket.

  ## Examples

      iex> create_ticket(scope, %{field: value})
      {:ok, %Ticket{}}

      iex> create_ticket(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticket(%Scope{} = scope, attrs) do
    with {:ok, %Ticket{} = ticket} <-
           %Ticket{}
           |> Ticket.changeset(attrs, scope)
           |> Repo.insert() do
      ticket_with_user = ticket |> Repo.preload(:user)
      broadcast("raffle:#{ticket.raffle_id}", {:created, ticket_with_user})
      {:ok, ticket}
    end
  end

  @doc """
  Updates a ticket.

  ## Examples

      iex> update_ticket(scope, ticket, %{field: new_value})
      {:ok, %Ticket{}}

      iex> update_ticket(scope, ticket, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticket(%Scope{} = scope, %Ticket{} = ticket, attrs) do
    true = ticket.user_id == scope.user.id

    with {:ok, %Ticket{} = ticket} <-
           ticket
           |> Ticket.changeset(attrs, scope)
           |> Repo.update() do
      {:ok, ticket}
    end
  end

  @doc """
  Deletes a ticket.

  ## Examples

      iex> delete_ticket(scope, ticket)
      {:ok, %Ticket{}}

      iex> delete_ticket(scope, ticket)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticket(%Scope{} = scope, %Ticket{} = ticket) do
    true = ticket.user_id == scope.user.id

    with {:ok, ticket = %Ticket{}} <-
           Repo.delete(ticket) do
      {:ok, ticket}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticket changes.

  ## Examples

      iex> change_ticket(scope, ticket)
      %Ecto.Changeset{data: %Ticket{}}

  """

  def change_ticket(%Scope{} = scope, %Ticket{} = ticket, attrs \\ %{}) do
    Ticket.changeset(ticket, attrs, scope)
  end
end
