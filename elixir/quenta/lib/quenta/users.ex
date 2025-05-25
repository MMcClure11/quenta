defmodule Quenta.Users do
  alias Quenta.Repo
  alias Quenta.Users.User

  def list_users do
    Repo.all(User)
  end
end
