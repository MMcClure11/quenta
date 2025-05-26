defmodule Quenta.Counter do
  use GenServer

  @topic "counter"

  # Client API

  def start_link(opts \\ []) do
    initial_value = Keyword.get(opts, :initial_value, 0)
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, initial_value, name: name)
  end

  def increment(pid \\ __MODULE__) do
    GenServer.cast(pid, :increment)
  end

  def decrement(pid \\ __MODULE__) do
    GenServer.cast(pid, :decrement)
  end

  def get_value(pid \\ __MODULE__) do
    GenServer.call(pid, :get_value)
  end

  # Server API

  def init(initial_value) do
    dbg("Initializing counter with value: #{initial_value}")
    {:ok, initial_value}
  end

  def handle_cast(:increment, state) do
    next_value = state + 1
    broadcast_update(next_value)
    {:noreply, next_value}
  end

  def handle_cast(:decrement, state) do
    next_value = state - 1
    broadcast_update(next_value)
    {:noreply, next_value}
  end

  def handle_call(:get_value, _from, state) do
    {:reply, state, state}
  end

  # PubSub integration

  defp broadcast_update(value) do
    Phoenix.PubSub.broadcast(Quenta.PubSub, @topic, {:counter_updated, value})
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Quenta.PubSub, @topic)
  end
end
