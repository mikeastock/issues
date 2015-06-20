defmodule CLITest do
  use ExUnit.Case

  import Issues.CLI, only: [ parse_args: 1 ]

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
end
