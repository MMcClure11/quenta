defmodule Quenta.Expenses do
  alias Quenta.Repo
  alias Quenta.Expenses.Expense

  def create_expense(attrs) do
    %Expense{}
    |> Expense.changeset(attrs)
    |> Repo.insert()
  end

  def list_expenses do
    Repo.all(Expense)
  end
end
