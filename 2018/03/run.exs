### Main logic
defmodule Aoc do
  @pattern ~r/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/

  def solve1(input) do
    input
    |> Enum.map(&parse_line/1)
    |> build_map
    |> Enum.count(fn {_k, ids} -> length(ids) > 1 end)
  end

  def solve2(input) do
    lines = Enum.map(input, &parse_line/1)
    map = build_map(lines)

    all_ids = lines |> Enum.map(fn {id, _} -> id end) |> Enum.into(MapSet.new())

    covered_ids =
      map
      |> Enum.filter(fn {_k, ids} -> length(ids) > 1 end)
      |> Enum.reduce(MapSet.new(), fn {_k, ids}, acc ->
        MapSet.union(acc, MapSet.new(ids))
      end)

    MapSet.difference(all_ids, covered_ids) |> MapSet.to_list() |> hd
  end

  def build_map(lines) do
    Enum.reduce(lines, %{}, &feed_line/2)
  end

  def feed_line({id, area}, map) do
    cells(area)
    |> Enum.reduce(map, fn coords, map ->
      Map.update(map, coords, [id], &[id | &1])
    end)
  end

  def parse_line(line) do
    [id, left, top, width, height] =
      Regex.run(@pattern, line, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    {id, {left, top, width, height}}
  end

  def cells({l, t, w, h}) do
    for x <- l..(l + w - 1), y <- t..(t + h - 1), do: {x, y}
  end
end

### Actual run
input = File.read!("input.txt")
|> String.split("\n", trim: true)

IO.inspect(Aoc.solve1(input), label: "First part")
IO.inspect(Aoc.solve2(input), label: "Second part")

### Tests
ExUnit.start()

defmodule Test do
  use ExUnit.Case
  import Aoc

  test "first part" do
    assert solve1([
             "#1 @ 1,3: 4x4",
             "#2 @ 3,1: 4x4",
             "#3 @ 5,5: 2x2"
           ]) == 4
  end

  test "second part" do
    assert solve2([
             "#1 @ 1,3: 4x4",
             "#2 @ 3,1: 4x4",
             "#3 @ 5,5: 2x2"
           ]) == 3
  end
end
