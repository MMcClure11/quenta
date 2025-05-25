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
    <p>
      Would you like to <.link href={~p"/expenses/new"} class="text-blue-500 hover:underline">add an expense</.link>?
    </p>
    """
  end
end
