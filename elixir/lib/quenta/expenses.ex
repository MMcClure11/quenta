defmodule Quenta.Expenses do
  alias Quenta.Repo
  alias Quenta.Expenses.Expense

  def change_expense(expense, attrs) do
    expense |> Expense.changeset(attrs)
  end

  def create_expense(attrs) do
    %Expense{} |> Expense.changeset(attrs) |> Repo.insert()
  end

  def list_expenses(opts \\ []) do
    preloads = Keyword.get(opts, :preloads, [])
    Expense |> Repo.all() |> Repo.preload(preloads)
  end
end
