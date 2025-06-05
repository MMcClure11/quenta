defmodule QuentaWeb.ExpensesLive.Index do
  use QuentaWeb, :live_view

  alias Quenta.Expenses

  def mount(_params, _session, socket) do
    expenses = Expenses.list_expenses(preloads: [:user, [expense_items: :user]])
    {:ok, assign(socket, :expenses, expenses)}
  end

  def render(assigns) do
    ~H"""
    <div :for={expense <- @expenses}>
      <div class="flex flex-row gap-3">
        <p class="font-bold">{expense.description}</p>
        <p class="">{expense.date}</p>
        <p class="">${expense.amount_cents / 100}</p>
        <p class="">Paid By: {expense.user.name}</p>
      </div>
      <div :for={expense_item <- expense.expense_items} class="ml-6 flex flex-row gap-3">
        <p class="font-bold">{expense_item.description}</p>
        <p class="">${expense_item.amount_cents / 100}</p>
        <p class="">For: {expense_item.user.name}</p>
      </div>
    </div>
    """
  end
end
