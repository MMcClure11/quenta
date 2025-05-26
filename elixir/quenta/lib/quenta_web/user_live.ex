defmodule QuentaWeb.UserLive do
  use QuentaWeb, :live_view
  alias Quenta.Users

  def mount(%{"user_id" => user_id}, _session, socket) do
    Quenta.Counter.subscribe()

    user = Users.get_user!(user_id)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:counter_value, Quenta.Counter.get_value())

    {:ok, socket}
  end

  def handle_event("increment", _params, socket) do
    Quenta.Counter.increment()
    {:noreply, socket}
  end

  def handle_event("decrement", _params, socket) do
    Quenta.Counter.decrement()
    {:noreply, socket}
  end

  def handle_info({:counter_updated, value}, socket) do
    # Update the socket with the new counter value
    {:noreply, assign(socket, counter_value: value)}
  end

  def render(assigns) do
    ~H"""
    <p>Hello {@user.name}</p>
    <p>
      Would you like to <.link href={~p"/expenses/new"} class="text-blue-500 hover:underline">add an expense</.link>?
    </p>
    <.counter counter_value={@counter_value} />
    """
  end

  defp counter(assigns) do
    ~H"""
    <div class="flex items-center space-x-4">
      <button phx-click="increment" class="px-4 py-2 bg-blue-500 text-white rounded">
        Increment
      </button>
      <span class="text-lg font-bold">{@counter_value}</span>
      <button phx-click="decrement" class="px-4 py-2 bg-red-500 text-white rounded">Decrement</button>
    </div>
    """
  end
end
