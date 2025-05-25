defmodule Quenta.ExpenseItems.ExpenseItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expense_items" do
    field :description, :string
    field :amount_cents, :integer

    belongs_to :expense, Quenta.Expenses.Expense
    belongs_to :user, Quenta.Users.User

    timestamps()
  end

  @fields ~w(description amount_cents expense_id user_id)a

  def changeset(expense_item, attrs) do
    expense_item
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_number(:amount_cents, greater_than: 0)
    |> assoc_constraint(:expense)
    |> assoc_constraint(:user)
  end
end
