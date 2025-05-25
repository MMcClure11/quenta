defmodule QuentaWeb.ExpenseLive.New do
  use QuentaWeb, :live_view
  alias Quenta.Expenses.Expense
  alias Quenta.Expenses
  alias Quenta.Users

  def mount(_params, _session, socket) do
    form = build_form(%{})

    user_options =
      Users.list_users()
      |> Enum.map(fn user -> {user.name, user.id} end)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:user_options, user_options)

    {:ok, socket}
  end

  def handle_event("validate", params, socket) do
    %{"expense" => attrs} = params

    # Convert amount from string to integer (cents)
    %{"amount_cents" => amount_dollars} = attrs
    amount_cents = price_to_cents(amount_dollars)
    attrs = Map.put(attrs, "amount_cents", amount_cents)

    form =
      %Expense{}
      |> Expenses.change_expense(attrs)
      |> to_form(action: :validate)

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", params, socket) do
    %{"expense" => attrs} = params

    # Convert amount from string to integer (cents)
    %{"amount_cents" => amount_dollars} = attrs
    amount_cents = price_to_cents(amount_dollars)
    attrs = Map.put(attrs, "amount_cents", amount_cents)

    case Expenses.create_expense(attrs) do
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
      <.input label="Description" type="text" field={@form[:description]} />
      <.input label="Amount" type="number" field={@form[:amount_cents]} step="0.01" />
      <.input label="Date" type="date" field={@form[:date]} />
      <.input
        label="Paid By"
        type="select"
        field={@form[:user_id]}
        options={@user_options}
        prompt="Select User"
      />
      <button>Save</button>
    </.form>
    """
  end

  defp build_form(attrs) do
    to_form(Expenses.change_expense(%Expense{}, attrs))
  end

  defp price_to_cents("") do
    ""
  end

  defp price_to_cents(price_string) do
    float_val =
      if String.contains?(price_string, ".") do
        String.to_float(price_string)
      else
        String.to_integer(price_string) |> :erlang.float()
      end

    round(float_val * 100)
  end
end
