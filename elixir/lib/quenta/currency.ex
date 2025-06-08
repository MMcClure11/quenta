defmodule Quenta.Currency do
  @moduledoc """
  Module to handle currency transformations.
  """

  @doc """
  Formats a number into a human-readable string with comma separators for thousands.

  ## Examples

      iex> format_cents_to_dollars(1234567.89)
      "$1,234,567.89"

      iex> format_cents_to_dollars(12345)
      "$12,345.00"

      iex> format_cents_to_dollars(123.45)
      "$123.45"

      iex> format_cents_to_dollars(1234567)
      "$1,234,567.00"

      iex> format_cents_to_dollars(-12345.67)
      "$-12,345.67"

      iex> format_cents_to_dollars(0)
      "$0.00"

      iex> format_cents_to_dollars(0.123)
      "$0.12"

      iex> format_cents_to_dollars(-0.123)
      "$-0.12"

      iex> format_cents_to_dollars(123456789.12345)
      "$123,456,789.12"
  """
  def format_cents_to_dollars(amount_cents) do
    dollars = amount_cents / 100

    is_negative = dollars < 0

    abs_number_string =
      :erlang.float_to_binary(abs(dollars), decimals: 2)
      |> to_string()

    {integer_part_string, fractional_part_string} =
      case String.split(abs_number_string, ".", parts: 2) do
        [int_part] -> {int_part, ""}
        [int_part, frac_part] -> {int_part, "." <> frac_part}
      end

    formatted_integer_part =
      integer_part_string
      |> String.reverse()
      |> String.graphemes()
      |> Enum.chunk_every(3)
      |> Enum.join(",")
      |> String.reverse()

    prefix = if is_negative, do: "-", else: ""
    formatted_dollars = prefix <> formatted_integer_part <> fractional_part_string
    "$#{formatted_dollars}"
  end
end
