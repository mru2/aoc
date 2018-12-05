### Main logic
defmodule Aoc do
  def solve1(input) do
    input
    |> to_charlist
    |> collapse
    |> length
  end

  def solve2(input) do
    input = to_charlist(input)

    # A - Z in charcodes
    65..90
    |> Enum.map(fn charcode ->
      input
      |> clear(charcode)
      |> collapse
      |> length
    end)
    |> Enum.min()
  end

  defp clear(input, charcode),
    do: input |> Enum.reject(fn c -> c == charcode || c == charcode + 32 end)

  defp collapse(input), do: delete_pairs(input, &react?/1)

  defp react?({a, b}) when a - b == 32, do: true
  defp react?({a, b}) when b - a == 32, do: true
  defp react?(_), do: false

  # Delete matching pairs, without a guaranty on keeping the list order (also assumes the final list is not empty)
  defp delete_pairs(list, matcher), do: delete_pairs(list, matcher, [], false)
  defp delete_pairs([], _matcher, acc, false), do: acc
  defp delete_pairs([last], _matcher, acc, false), do: [last | acc]
  defp delete_pairs([], matcher, acc, true), do: delete_pairs(acc, matcher)
  defp delete_pairs([last], matcher, acc, true), do: delete_pairs([last | acc], matcher)

  defp delete_pairs([a, b | rest], matcher, acc, flag) do
    case matcher.({a, b}) do
      true -> delete_pairs(rest, matcher, acc, true)
      false -> delete_pairs([b | rest], matcher, [a | acc], flag)
    end
  end
end

### Actual run
input =
  File.read!("input.txt")
  |> String.split("\n", trim: true)
  |> hd

IO.inspect(Aoc.solve1(input), label: "First part")
IO.inspect(Aoc.solve2(input), label: "Second part")

### Tests
ExUnit.start()

defmodule Test do
  use ExUnit.Case
  import Aoc

  test "first part" do
    assert solve1("dabAcCaCBAcCcaDA") == 10
  end

  test "second part" do
    assert solve2("dabAcCaCBAcCcaDA") == 4
  end
end
