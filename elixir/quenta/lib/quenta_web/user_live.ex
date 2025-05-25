defmodule QuentaWeb.UserLive do
  use QuentaWeb, :live_view
  alias Quenta.Users

  def mount(%{"user_id" => user_id}, _session, socket) do
    user = Users.get_user!(user_id)
    {:ok, assign(socket, user: user)}
  end

  def render(assigns) do
    ~H"""
    <p>Hello {@user.name}</p>
    """
  end
end
