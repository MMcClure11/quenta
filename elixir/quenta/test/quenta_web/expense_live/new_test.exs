defmodule QuentaWeb.ExpenseLive.NewTest do
  use QuentaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders new expense form", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/expenses/new")

    assert render(view) =~ "Description"
    assert render(view) =~ "Amount"
    assert render(view) =~ "Date"
    assert render(view) =~ "Paid By"
  end

  test "creates a new expense", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/expenses/new")

    view
    |> element("form")
    |> render_submit(%{
      expense: %{
        amount_cents: "100.00",
        description: "Test Expense",
        user_id: "1",
        date: "2023-10-01"
      }
    })

    assert_redirected(view, ~p"/")
  end

  test "displays validation errors", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/expenses/new")

    view
    |> element("form")
    |> render_submit(%{
      expense: %{
        amount_cents: "",
        description: "",
        user_id: "",
        date: ""
      }
    })

    assert render(view) =~ "can&#39;t be blank"
  end
end
