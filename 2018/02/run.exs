### Main logic
defmodule Aoc do
  def solve1(input) do
    counts =
      input
      |> Enum.map(&String.codepoints/1)
      |> Enum.map(&count_unique/1)

    doubles = Enum.count(counts, &MapSet.member?(&1, 2))
    triples = Enum.count(counts, &MapSet.member?(&1, 3))
    doubles * triples
  end

  def solve2(input) do
    input
    |> Enum.map(&String.codepoints/1)
    |> find_pair
    |> merge
  end

  def dist([], []), do: 0
  def dist([h | t1], [h | t2]), do: dist(t1, t2)
  def dist([_h1 | t1], [_h2 | t2]), do: 1 + dist(t1, t2)

  def find_pair([l | t]) do
    case Enum.find(t, &(dist(&1, l) == 1)) do
      nil -> find_pair(t)
      match -> {l, match}
    end
  end

  def merge({[], []}), do: ""
  def merge({[h | t1], [h | t2]}), do: h <> merge({t1, t2})
  def merge({[_h1 | t1], [_h2 | t2]}), do: merge({t1, t2})

  def count_unique(charlist) do
    charlist
    |> Enum.group_by(& &1)
    |> Enum.map(fn {_k, v} ->
      length(v)
    end)
    |> Enum.into(MapSet.new())
  end
end

### Actual run
input =
  File.read!("input.txt")
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
             "abcdef",
             "bababc",
             "abbcde",
             "abcccd",
             "aabcdd",
             "abcdee",
             "ababab"
           ]) == 12
  end

  test "second part" do
    assert solve2([
             "abcde",
             "fghij",
             "klmno",
             "pqrst",
             "fguij",
             "axcye",
             "wvxyz"
           ]) == "fgij"
  end
end
