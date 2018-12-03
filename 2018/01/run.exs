### Main logic
defmodule Aoc do
  def solve1(input) do
    input
    |> Enum.sum()
  end

  def solve2(input) do
    Stream.cycle(input)
    |> Enum.reduce_while({0, MapSet.new([0])}, &find_duplicate/2)
  end

  def find_duplicate(i, {acc, cache}) do
    new = acc + i

    if MapSet.member?(cache, new) do
      {:halt, new}
    else
      {:cont, {new, MapSet.put(cache, new)}}
    end
  end
end

### Actual run
input =
  File.read!("input.txt")
  |> String.split("\n", trim: true)
  |> Enum.map(&String.to_integer/1)

IO.inspect(Aoc.solve1(input), label: "First part")
IO.inspect(Aoc.solve2(input), label: "Second part")

### Tests
ExUnit.start()

defmodule Test do
  use ExUnit.Case
  import Aoc

  test "first part" do
    assert solve1([1, 1, 1]) == 3
    assert solve1([1, 1, -2]) == 0
    assert solve1([-1, -2, -3]) == -6
  end

  test "second part" do
    assert solve2([1, -1]) == 0
    assert solve2([3, 3, 4, -2, -4]) == 10
    assert solve2([-6, +3, +8, +5, -6]) == 5
    assert solve2([+7, +7, -2, -7, -4]) == 14
  end
end
