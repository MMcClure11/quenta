defmodule QuentaWeb.ExpenseLive.New do
  use QuentaWeb, :live_view

  alias Quenta.Expenses
  alias Quenta.Expenses.Expense
  alias Quenta.Users

  def mount(_params, _session, socket) do
    form = %Expense{} |> Expenses.change_expense(%{}) |> to_form()
    user_options = Users.list_users() |> Enum.map(fn user -> {user.name, user.id} end)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:user_options, user_options)

    {:ok, socket}
  end

  def handle_event("validate", %{"expense" => expense_attrs}, socket) do
    form = %Expense{} |> Expenses.change_expense(expense_attrs) |> to_form(action: :validate)
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"expense" => expense_attrs}, socket) do
    case Expenses.create_expense(expense_attrs) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Expense created!")
         |> redirect(to: ~p"/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <.form for={@form} phx-change="validate" phx-submit="save">
      <div class="flex flex-col gap-3">
        <.input label="Description" type="text" field={@form[:description]} />
        <.input label="Amount" type="number" field={@form[:amount_dollars]} step="0.01" />
        <.input
          label="Date"
          type="date"
          field={@form[:date]}
          value={Date.utc_today() |> Date.to_iso8601()}
        />
        <.input label="Paid By" type="select" field={@form[:user_id]} options={@user_options} />
      </div>

      <h3 class="font-lg font-bold mt-6 mb-3">Expense Items</h3>
      <.inputs_for :let={eif} field={@form[:expense_items]}>
        <input type="hidden" name="expense[expense_items_sort][]" value={eif.index} />
        <div class="flex flex-row gap-3 w-full border-2 p-4 my-2 rounded-md">
          <div class="flex flex-col gap-3 grow">
            <.input label="Description" type="text" field={eif[:description]} />
            <.input label="Amount" type="number" field={eif[:amount_dollars]} step="0.01" />
            <.input label="Bought By" type="select" field={eif[:user_id]} options={@user_options} />
          </div>

          <button
            type="button"
            name="expense[expense_items_drop][]"
            value={eif.index}
            phx-click={JS.dispatch("change")}
            class="justify-start"
          >
            <.icon name="hero-x-mark" class="w-6 h-6 hover:text-red-500" />
          </button>
        </div>
      </.inputs_for>

      <input type="hidden" name="expense[expense_items_drop][]" />

      <div class="flex flex-row gap-3 my-3">
        <button
          type="button"
          name="expense[expense_items_sort][]"
          value="new"
          class="p-2 bg-blue-300 hover:bg-blue-400 rounded-md"
          phx-click={JS.dispatch("change")}
        >
          Add Expense Item
        </button>
        <button
          class="p-2 bg-blue-300 hover:bg-blue-400 disabled:bg-gray-400 rounded-md"
          disabled={!@form.source.valid?}
        >
          Save
        </button>
      </div>
    </.form>
    """
  end
end
