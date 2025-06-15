defmodule QuentaWeb.UserLive do
  use QuentaWeb, :live_view

  import Quenta.Currency

  alias Quenta.ExpenseCalculator
  alias Quenta.Expenses
  alias Quenta.Users

  def mount(%{"user_id" => user_id}, _session, socket) do
    user = Users.get_user!(user_id)
    # Preload both user and expense_items with their associated users
    expenses = Expenses.list_expenses(preloads: [:user, expense_items: [:user]])

    # Get all users for calculations
    all_users = Users.list_users()
    other_user = Enum.find(all_users, fn u -> u.id != user.id end)

    # Calculate balances for each expense
    expenses_with_balances = calculate_expenses_with_balances(expenses, all_users, user.id)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:other_user, other_user)
      |> assign(:all_users, all_users)
      |> assign(:expenses, expenses_with_balances)
      |> assign(
        :running_total_cents,
        calculate_running_total_cents(expenses_with_balances, user.id)
      )

    {:ok, socket}
  end

  def handle_event("logout", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/")}
  end

  defp calculate_expenses_with_balances(expenses, all_users, current_user_id) do
    Enum.map(expenses, fn expense ->
      # Calculate balances for this expense
      balances = ExpenseCalculator.calculate_balances(expense, expense.expense_items, all_users)

      # Find current user's balance for this expense
      current_user_balance = Enum.find(balances, &(&1.user.id == current_user_id))

      # Add balance info to expense
      Map.put(expense, :user_balance, current_user_balance.balance)
    end)
  end

  defp calculate_running_total_cents(expenses_with_balances, _current_user_id) do
    Enum.reduce(expenses_with_balances, 0, fn expense, total ->
      total + expense.user_balance
    end)
  end

  defp format_date(date) do
    Calendar.strftime(date, "%b %-d, %Y")
  end

  defp get_expense_emoji(description) do
    description_lower = String.downcase(description)

    cond do
      String.contains?(description_lower, ["grocery", "food", "market"]) -> "🛒"
      String.contains?(description_lower, ["dinner", "restaurant", "pizza", "italian"]) -> "🍝"
      String.contains?(description_lower, ["uber", "taxi", "ride"]) -> "🚗"
      String.contains?(description_lower, ["coffee", "cafe", "pastry"]) -> "☕"
      String.contains?(description_lower, ["gas", "fuel"]) -> "⛽"
      String.contains?(description_lower, ["movie", "cinema"]) -> "🎬"
      String.contains?(description_lower, ["drink", "bar", "beer"]) -> "🍺"
      true -> "💰"
    end
  end

  defp format_expense_balance(expense, current_user) do
    cond do
      expense.user_balance > 0 ->
        # Current user owes money
        {"You owe", format_cents_to_dollars(expense.user_balance), "text-red-400"}

      expense.user_balance < 0 ->
        # Current user is owed money
        {"You lent", format_cents_to_dollars(abs(expense.user_balance)), "text-green-400"}

      true ->
        # Balanced
        {"Even", "$0.00", "text-slate-400"}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-900 text-white">
      <!-- Header -->
      <div class="bg-slate-800 border-b border-slate-700">
        <div class="max-w-4xl mx-auto px-4 py-6">
          <div class="flex items-center justify-between">
            <div>
              <h1 class="text-2xl font-bold">Quenta</h1>
              <p class="text-slate-200 capitalize">Welcome back, {@user.name}!</p>
            </div>
            <button
              phx-click="logout"
              class="inline-flex items-center gap-2 rounded-md border border-slate-500 bg-transparent px-3 py-2 text-sm font-medium text-slate-200 hover:bg-slate-700 hover:text-white focus:outline-none focus:ring-2 focus:ring-slate-500 focus:ring-offset-2 focus:ring-offset-slate-900"
            >
              <.icon name="hero-arrow-right-start-on-rectangle" class="w-4 h-4" /> Logout
            </button>
          </div>
        </div>
      </div>

      <div class="max-w-4xl mx-auto px-4 py-8">
        <!-- Running Total -->
        <div class="rounded-lg border border-slate-700 bg-slate-800 text-slate-200 shadow-sm mb-8">
          <div class="p-6">
            <div class="text-center">
              <h2 class="text-lg font-medium text-slate-200 mb-2">Current Balance</h2>
              <div class="text-3xl font-bold">
                <%= if @running_total_cents >= 0 do %>
                  <span class="text-red-400">
                    You owe {@other_user.name} {format_cents_to_dollars(@running_total_cents)}
                  </span>
                <% else %>
                  <span class="text-green-400">
                    {@other_user.name} owes you {format_cents_to_dollars(abs(@running_total_cents))}
                  </span>
                <% end %>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Add Expense Button -->
        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6 gap-4">
          <h2 class="text-xl font-semibold">Recent Expenses</h2>
          <.link
            navigate={~p"/users/#{@user.id}/expenses/new"}
            class="inline-flex items-center gap-2 rounded-md bg-blue-600 px-3 py-2 text-sm font-semibold text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 focus:ring-offset-slate-900"
          >
            <.icon name="hero-plus" class="w-4 h-4" /> Add Expense
          </.link>
        </div>
        
    <!-- Expenses List -->
        <div class="space-y-4">
          <%= for expense <- @expenses do %>
            <div class="rounded-lg border border-slate-700 bg-slate-800 text-slate-200 shadow-sm">
              <div class="p-4">
                <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                  <div class="flex items-center space-x-4">
                    <div class="text-2xl flex-shrink-0">{get_expense_emoji(expense.description)}</div>
                    <div class="min-w-0 flex-1">
                      <h3 class="font-medium text-white truncate">{expense.description}</h3>
                      <p class="text-sm text-slate-300">{format_date(expense.date)}</p>
                      
    <!-- Show expense items if any -->
                      <%= if length(expense.expense_items) > 0 do %>
                        <div class="mt-2 space-y-1">
                          <%= for item <- expense.expense_items do %>
                            <div class="text-xs text-slate-400 flex justify-between">
                              <span>{item.description} ({item.user.name})</span>
                              <span>{format_cents_to_dollars(item.amount_cents)}</span>
                            </div>
                          <% end %>
                        </div>
                      <% end %>
                    </div>
                  </div>
                  <div class="text-right sm:flex-shrink-0">
                    <div class="font-semibold text-white">
                      {format_cents_to_dollars(expense.amount_cents)}
                    </div>
                    <div class="text-sm text-slate-300 capitalize">
                      Paid by {expense.user.name}
                    </div>
                    <div class="text-sm mt-1">
                      <% {label, amount, color_class} = format_expense_balance(expense, @user) %>
                      <span class={color_class}>
                        {label} {amount}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          <% end %>
        </div>

        <%= if @expenses == [] do %>
          <div class="text-center py-12">
            <p class="text-slate-400 text-lg">No expenses yet</p>
            <p class="text-slate-500 mt-2">Add your first expense to get started!</p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
