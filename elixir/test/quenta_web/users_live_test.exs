defmodule QuentaWeb.UserLiveTest do
  use QuentaWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Quenta.Users

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Quenta.Repo)
  end

  describe "UserLive" do
    setup do
      george = Users.get_user!(1)
      meks = Users.get_user!(2)

      %{george: george, meks: meks}
    end

    test "displays user welcome message", %{conn: conn, meks: meks} do
      {:ok, _view, html} = live(conn, ~p"/users/#{meks.id}")

      assert html =~ "Welcome back, Meks!"
      assert html =~ "Quenta"
    end

    test "displays logout button and handles logout", %{conn: conn, meks: meks} do
      {:ok, view, html} = live(conn, ~p"/users/#{meks.id}")

      assert html =~ "Logout"

      # Test logout functionality
      assert {:ok, conn} =
               view |> element("button", "Logout") |> render_click() |> follow_redirect(conn)

      assert redirected_to(conn) == "/"
    end

    test "displays add expense button", %{conn: conn, meks: meks} do
      {:ok, _view, html} = live(conn, ~p"/users/#{meks.id}")

      assert html =~ "Add Expense"
      assert html =~ ~p"/users/#{meks.id}/expenses/new"
    end

    test "displays empty state when no expenses", %{conn: conn, meks: meks} do
      {:ok, _view, html} = live(conn, ~p"/users/#{meks.id}")

      assert html =~ "No expenses yet"
      assert html =~ "Add your first expense to get started!"
    end
  end

  describe "UserLive error cases" do
    test "handles non-existent user", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/users/999")
      end
    end
  end
end
