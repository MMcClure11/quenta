defmodule Quenta.CounterTest do
  use ExUnit.Case, async: true

  setup do
    counter = start_supervised!({Quenta.Counter, [name: nil]})
    %{counter: counter}
  end

  test "verify initial value", %{counter: counter} do
    value = Quenta.Counter.get_value(counter)
    assert 0 = value
  end

  test "increment", %{counter: counter} do
    Quenta.Counter.increment(counter)
    value = Quenta.Counter.get_value(counter)
    assert 1 = value
  end

  test "decrement", %{counter: counter} do
    Quenta.Counter.decrement(counter)
    value = Quenta.Counter.get_value(counter)
    assert -1 = value
  end
end
