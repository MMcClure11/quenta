defmodule Quenta.UsersTest do
  use ExUnit.Case, async: true
  alias Quenta.Users

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Quenta.Repo)
  end

  test "list_users/0 returns all users" do
    assert [george, meks] = Users.list_users()
    assert george.name == "George"
    assert meks.name == "Meks"
  end
end
