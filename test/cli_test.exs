defmodule CLITest do
  use ExUnit.Case
  use Timex

  import Issues.CLI, only: [ parse_args: 1,
                             convert_to_list_of_hashdicts: 1,
                             sort_by_created_at: 2 ]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h", "test"]) == :help
    assert parse_args(["--help", "test"]) == :help
  end

  test "three values returned if three given" do
    assert parse_args(["user", "project", "10"]) == { "user", "project", 10 }
  end

  test "default count is returned if two given" do
    assert parse_args(["user", "project"]) == { "user", "project", 4 }
  end

  test "sort created_at asc" do
    issues = issues_list
    assert sort_by_created_at(issues, :asc) == Enum.sort(issues)
  end

  test "sort created_at desc" do
    issues = issues_list
    assert sort_by_created_at(issues, :desc) == Enum.reverse(Enum.sort(issues))
  end

  defp issues_list do
    Enum.into(1..3, [])
    |> Enum.map(fn _ -> %{created_at: DateFormat.format!(Date.now, "{ISO}")} end)
  end
end
