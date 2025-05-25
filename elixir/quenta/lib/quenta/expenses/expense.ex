defmodule Quenta.Expenses.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expenses" do
    field :description, :string
    field :date, :date
    field :amount_cents, :integer

    belongs_to :user, Quenta.Users.User

    has_many :expense_items, Quenta.ExpenseItems.ExpenseItem

    timestamps()
  end

  @fields ~w(description date amount_cents user_id)a

  def changeset(expense, attrs) do
    expense
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_number(:amount_cents, greater_than: 0)
    |> assoc_constraint(:user)
  end
end
