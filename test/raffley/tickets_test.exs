defmodule Raffley.TicketsTest do
  use Raffley.DataCase

  alias Raffley.Tickets
  alias Raffley.Tickets.Ticket

  import Raffley.AccountsFixtures, only: [user_scope_fixture: 0]
  import Raffley.TicketsFixtures
  import Raffley.RafflesFixtures

  setup do
    scope = user_scope_fixture()
    raffle = raffle_fixture()
    ticket = ticket_fixture(scope, raffle_id: raffle.id)
    %{raffle: raffle, scope: scope, ticket: ticket}
  end

  describe "tickets" do
    test "list_tickets/1 returns all scoped tickets", %{
      ticket: ticket,
      scope: scope,
      raffle: raffle
    } do
      other_scope = user_scope_fixture()
      other_ticket = ticket_fixture(other_scope, raffle_id: raffle.id)
      assert Tickets.list_tickets(scope) == [ticket]
      assert Tickets.list_tickets(other_scope) == [other_ticket]
    end

    test "get_ticket!/2 returns the ticket with given id", %{ticket: ticket, scope: scope} do
      other_scope = user_scope_fixture()
      assert Tickets.get_ticket!(scope, ticket.id) == ticket
      assert_raise Ecto.NoResultsError, fn -> Tickets.get_ticket!(other_scope, ticket.id) end
    end

    test "create_ticket/2 with valid data creates a ticket", %{scope: scope} do
      raffle = raffle_fixture()
      valid_attrs = %{comment: "some comment", price: 42, raffle_id: raffle.id}

      assert {:ok, %Ticket{} = ticket} = Tickets.create_ticket(scope, valid_attrs)
      assert ticket.comment == "some comment"
      assert ticket.price == 42
      assert ticket.user_id == scope.user.id
      assert ticket.raffle_id == raffle.id
    end

    test "create_ticket/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      invalid_attrs = %{comment: nil, price: nil}
      assert {:error, %Ecto.Changeset{}} = Tickets.create_ticket(scope, invalid_attrs)
    end

    test "update_ticket/3 with valid data updates the ticket", %{ticket: ticket, scope: scope} do
      update_attrs = %{comment: "some updated comment", price: 43}

      assert {:ok, %Ticket{} = ticket} = Tickets.update_ticket(scope, ticket, update_attrs)
      assert ticket.comment == "some updated comment"
      assert ticket.price == 43
    end

    test "update_ticket/3 with invalid scope raises", %{ticket: ticket} do
      other_scope = user_scope_fixture()

      assert_raise MatchError, fn ->
        Tickets.update_ticket(other_scope, ticket, %{})
      end
    end

    test "update_ticket/3 with invalid data returns error changeset", %{
      ticket: ticket,
      scope: scope
    } do
      invalid_attrs = %{comment: nil, price: nil}
      assert {:error, %Ecto.Changeset{}} = Tickets.update_ticket(scope, ticket, invalid_attrs)
      assert ticket == Tickets.get_ticket!(scope, ticket.id)
    end

    test "delete_ticket/2 deletes the ticket", %{ticket: ticket, scope: scope} do
      assert {:ok, %Ticket{}} = Tickets.delete_ticket(scope, ticket)
      assert_raise Ecto.NoResultsError, fn -> Tickets.get_ticket!(scope, ticket.id) end
    end

    test "delete_ticket/2 with invalid scope raises", %{ticket: ticket} do
      other_scope = user_scope_fixture()
      assert_raise MatchError, fn -> Tickets.delete_ticket(other_scope, ticket) end
    end

    test "change_ticket/2 returns a ticket changeset", %{ticket: ticket, scope: scope} do
      assert %Ecto.Changeset{} = Tickets.change_ticket(scope, ticket)
    end
  end
end
