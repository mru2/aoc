### Main logic
defmodule Aoc do
  @line_pattern ~r/\[(?<ts>.*)\] ((?<down>falls asleep)|(?<up>wakes up)|Guard #(?<nb>\d+) begins shift)/

  def solve1(input) do
    planning = parse(input)
    {laziest, minutes} = Enum.max_by(planning, fn {_id, minutes} -> length(minutes) end)

    {max_minute, _count} = most_frequent(minutes)

    laziest * max_minute
  end

  def solve2(input) do
    {id, {minute, _count}} =
      input
      |> parse
      |> Enum.map(fn {id, minutes} -> {id, most_frequent(minutes)} end)
      |> Enum.max_by(fn {_id, {_minute, count}} -> count end)

    id * minute
  end

  def parse(input) do
    input
    |> Enum.sort()
    |> Enum.map(&parse_line/1)
    |> into_planning
  end

  # Recursively build planning
  def into_planning([{:change, id} | rest]), do: into_planning(rest, {:change, id}, id, %{})

  def into_planning([{:change, id} | rest], _last_log, _id, acc),
    do: into_planning(rest, {:change, id}, id, acc)

  def into_planning([{:up, up_at} | rest], {:down, down_at}, id, acc) do
    minutes = down_at..(up_at - 1) |> Enum.to_list()
    acc = append(acc, id, minutes)
    into_planning(rest, {:up, up_at}, id, acc)
  end

  def into_planning([log | rest], _last_log, id, acc), do: into_planning(rest, log, id, acc)
  def into_planning([], _last_log, _id, acc), do: acc

  def parse_line(line) do
    res = Regex.named_captures(@line_pattern, line)
    ts = NaiveDateTime.from_iso8601!(res["ts"] <> ":00")
    minute = NaiveDateTime.to_time(ts).minute

    case res do
      %{"down" => down} when down != "" -> {:down, minute}
      %{"up" => up} when up != "" -> {:up, minute}
      %{"nb" => nb} when nb != "" -> {:change, String.to_integer(nb)}
    end
  end

  defp append(map, id, elems), do: Map.update(map, id, elems, &(&1 ++ elems))

  defp most_frequent([]), do: {nil, 0}

  defp most_frequent(list) do
    list
    |> Enum.group_by(& &1)
    |> Enum.map(fn {k, list} -> {k, length(list)} end)
    |> Enum.max_by(fn {_k, count} -> count end)
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
             "[1518-11-01 00:00] Guard #10 begins shift",
             "[1518-11-01 00:05] falls asleep",
             "[1518-11-01 00:25] wakes up",
             "[1518-11-01 00:30] falls asleep",
             "[1518-11-01 00:55] wakes up",
             "[1518-11-01 23:58] Guard #99 begins shift",
             "[1518-11-02 00:40] falls asleep",
             "[1518-11-02 00:50] wakes up",
             "[1518-11-03 00:05] Guard #10 begins shift",
             "[1518-11-03 00:24] falls asleep",
             "[1518-11-03 00:29] wakes up",
             "[1518-11-04 00:02] Guard #99 begins shift",
             "[1518-11-04 00:36] falls asleep",
             "[1518-11-04 00:46] wakes up",
             "[1518-11-05 00:03] Guard #99 begins shift",
             "[1518-11-05 00:45] falls asleep",
             "[1518-11-05 00:55] wakes up"
           ]) == 240
  end

  test "second part" do
    assert solve2([
             "[1518-11-01 00:00] Guard #10 begins shift",
             "[1518-11-01 00:05] falls asleep",
             "[1518-11-01 00:25] wakes up",
             "[1518-11-01 00:30] falls asleep",
             "[1518-11-01 00:55] wakes up",
             "[1518-11-01 23:58] Guard #99 begins shift",
             "[1518-11-02 00:40] falls asleep",
             "[1518-11-02 00:50] wakes up",
             "[1518-11-03 00:05] Guard #10 begins shift",
             "[1518-11-03 00:24] falls asleep",
             "[1518-11-03 00:29] wakes up",
             "[1518-11-04 00:02] Guard #99 begins shift",
             "[1518-11-04 00:36] falls asleep",
             "[1518-11-04 00:46] wakes up",
             "[1518-11-05 00:03] Guard #99 begins shift",
             "[1518-11-05 00:45] falls asleep",
             "[1518-11-05 00:55] wakes up"
           ]) == 4455
  end
end
