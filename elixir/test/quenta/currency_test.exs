defmodule Quenta.CurrencyTest do
  use ExUnit.Case, async: true
  alias Quenta.Currency

  describe "format_cents_to_dollars/1" do
    test "formats 0" do
      assert "$0.00" = Currency.format_cents_to_dollars(0)
    end

    test "formats negative number" do
      assert "$-23.00" = Currency.format_cents_to_dollars(-2300)
    end

    test "formats small number" do
      assert "$0.23" = Currency.format_cents_to_dollars(23)
    end

    test "formats big number" do
      assert "$86,753.09" = Currency.format_cents_to_dollars(8_675_309)
    end

    test "rounds up" do
      assert "$0.01" = Currency.format_cents_to_dollars(0.5)
    end

    test "rounds down" do
      assert "$0.00" = Currency.format_cents_to_dollars(0.3)
    end
  end
end
