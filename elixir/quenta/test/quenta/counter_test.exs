defmodule Quenta.CounterTest do
  use ExUnit.Case, async: true

  setup do
    counter = start_supervised!({Quenta.Counter, [name: nil]})
    %{counter: counter}
  end

  test "verify initial value", %{counter: counter} do
    assert 0 = Quenta.Counter.get_value(counter)
  end

  test "increment", %{counter: counter} do
    Quenta.Counter.increment(counter)
    assert 1 = Quenta.Counter.get_value(counter)
  end

  test "super_boost", %{counter: counter} do
    Quenta.Counter.increment(counter)
    assert 1 = Quenta.Counter.get_value(counter)
    Quenta.Counter.increment(counter)
    assert 2 = Quenta.Counter.get_value(counter)
    Quenta.Counter.super_boost(6, counter)
    assert 12 = Quenta.Counter.get_value(counter)
  end

  test "decrement", %{counter: counter} do
    Quenta.Counter.decrement(counter)
    assert -1 = Quenta.Counter.get_value(counter)
  end
end
