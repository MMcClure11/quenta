defmodule Quenta.ExpensesTest do
  use ExUnit.Case, async: true
  alias Quenta.Expenses

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Quenta.Repo)
  end

  test "create_expense/1 creates a new expense" do
    params = %{
      "description" => "Lunch",
      "amount_cents" => 1500,
      "date" => ~D[2023-10-01],
      "user_id" => 1
    }

    assert {:ok, expense} = Expenses.create_expense(params)
    assert expense.description == "Lunch"
    assert expense.amount_cents == 1500
    assert expense.date == ~D[2023-10-01]
  end

  test "create_expense/1 returns an error when required fields are missing" do
    params = %{
      "description" => "Dinner",
      # Missing amount_cents
      "amount_cents" => nil,
      "date" => ~D[2023-10-01],
      "user_id" => 1
    }

    assert {:error, changeset} = Expenses.create_expense(params)
    assert changeset.valid? == false
    assert changeset.errors[:amount_cents] != nil
  end

  test "list_expenses/0 returns an empty list when no expenses exist" do
    assert [] = Expenses.list_expenses()
  end

  test "list_expenses/0 returns all expenses" do
    # Create an expense to test listing
    params = %{
      "description" => "Coffee",
      "amount_cents" => 500,
      "date" => ~D[2023-10-02],
      "user_id" => 1
    }

    {:ok, _expense} = Expenses.create_expense(params)

    assert [expense] = Expenses.list_expenses()
    assert expense.description == "Coffee"
    assert expense.amount_cents == 500
    assert expense.date == ~D[2023-10-02]
  end
end
