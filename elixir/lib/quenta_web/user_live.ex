defmodule QuentaWeb.UserLive do
  use QuentaWeb, :live_view

  alias Quenta.Users
  alias Quenta.Expenses

  def mount(%{"user_id" => user_id}, _session, socket) do
    user = Users.get_user!(user_id)
    expenses = Expenses.list_expenses(preloads: [:user])

    # Get all users for determining the "other" user
    all_users = Users.list_users()
    other_user = Enum.find(all_users, fn u -> u.id != user.id end)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:other_user, other_user)
      |> assign(:expenses, expenses)
      |> assign(:running_total, calculate_running_total(expenses, user.id))

    {:ok, socket}
  end

  def handle_event("logout", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/")}
  end

  defp calculate_running_total(expenses, current_user_id) do
    Enum.reduce(expenses, 0, fn expense, total ->
      # Divide by 200 to get half in dollars
      split_amount = expense.amount_cents / 200

      if expense.user_id == current_user_id do
        # Current user paid, so other user owes them
        total + split_amount
      else
        # Other user paid, so current user owes them
        total - split_amount
      end
    end)
  end

  defp format_currency(amount_cents) when is_integer(amount_cents) do
    amount_cents
    |> Kernel./(100)
    |> format_currency()
  end

  defp format_currency(amount) do
    :erlang.float_to_binary(amount / 1, decimals: 2)
    |> then(&"$#{&1}")
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
                <%= if @running_total >= 0 do %>
                  <span class="text-green-400">
                    {@other_user.name} owes you {format_currency(@running_total * 100)}
                  </span>
                <% else %>
                  <span class="text-red-400">
                    You owe {@other_user.name} {format_currency(abs(@running_total) * 100)}
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
            navigate={~p"/expenses/new"}
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
                    </div>
                  </div>
                  <div class="text-right sm:flex-shrink-0">
                    <div class="font-semibold text-white">
                      {format_currency(expense.amount_cents)}
                    </div>
                    <div class="text-sm text-slate-300 capitalize">
                      Paid by {expense.user.name}
                    </div>
                    <div class="text-sm mt-1">
                      <%= if expense.user_id == @user.id do %>
                        <span class="text-green-400">
                          You lent {format_currency(expense.amount_cents / 2)}
                        </span>
                      <% else %>
                        <span class="text-red-400">
                          You owe {format_currency(expense.amount_cents / 2)}
                        </span>
                      <% end %>
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
