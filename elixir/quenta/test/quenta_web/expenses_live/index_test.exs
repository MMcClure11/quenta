defmodule QuentaWeb.ExpensesLive.IndexTest do
  use QuentaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Quenta.Expenses

  test "renders list of expenses", %{conn: conn} do
    params = %{
      "description" => "Lunch",
      "amount_dollars" => 15.12,
      "date" => ~D[2023-10-01],
      "user_id" => 1
    }

    Expenses.create_expense(params)

    {:ok, view, _html} = live(conn, ~p"/expenses")

    assert render(view) =~ "Lunch"
    assert render(view) =~ "$15.12"
    assert render(view) =~ "2023-10-01"
  end
end
