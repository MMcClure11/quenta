defmodule QuentaWeb.ExpensesLive.NewTest do
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
        amount_dollars: "100.00",
        description: "Test Expense",
        user_id: "1",
        date: "2023-10-01"
      }
    })

    assert_redirected(view, ~p"/expenses")
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

  test "creates a new expense with expense items", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/expenses/new")

    view
    |> element("form")
    |> render_submit(%{
      expense: %{
        amount_dollars: "100.00",
        description: "Test Expense",
        user_id: "1",
        date: "2023-10-01",
        expense_items: %{
          "0" => %{
            description: "Item 1",
            amount_dollars: "50.00",
            user_id: "1"
          },
          "1" => %{
            description: "Item 2",
            amount_dollars: "30.00",
            user_id: "2"
          }
        }
      }
    })

    assert_redirected(view, ~p"/expenses")
  end

  test "displays validation errors for expense items", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/expenses/new")

    view
    |> element("form")
    |> render_submit(%{
      expense: %{
        amount_cents: "100.00",
        description: "Test Expense",
        user_id: "1",
        date: "2023-10-01",
        expense_items: %{
          "0" => %{
            description: "",
            amount_dollars: "",
            user_id: ""
          }
        }
      }
    })

    assert render(view) =~ "can&#39;t be blank"
  end
end
