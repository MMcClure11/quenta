defmodule Quenta.Currency do
  @moduledoc """
  Module to handle currency transformations.
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
