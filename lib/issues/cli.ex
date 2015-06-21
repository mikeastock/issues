defmodule Issues.CLI do

  import Issues.TableFormatter, only: [ print_table_for_columns: 2 ]

  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to various functions that end
  up generating a table of the last _n_ issues in a Github project
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  Otherwise it is a Github username, project name, and optionally the number of
  issues

  Return a tuple of `{ user, project, count }`, or `:help` if help was given
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean ],
                                       aliases: [ h: :help])

    case parse do
    { [help: true], _, _, } -> :help

    { _, [ user, project, count ], _ } -> { user, project, String.to_integer(count) }

    { _, [ user, project ], _ } -> { user, project, @default_count }

    _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> convert_to_list_of_hashdicts
    |> sort_by_created_at(:asc)
    |> Enum.take(count)
    |> print_table_for_columns(["number", "created_at", "title"])
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, body}) do
    { _, message } = List.keyfind(body, "message", 0)
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2)
  end

  def convert_to_list_of_hashdicts(list) do
    list
    |> Enum.map(&Enum.into(&1, HashDict.new))
  end

  def sort_by_created_at(:asc, list) do
    Enum.sort(list, fn item1, item2 -> item1.created_at <= item2.created_at end)
  end

  def sort_by_created_at(:desc, list) do
    Enum.sort(list, fn item1, item2 -> item1.created_at >= item2.created_at end)
  end
end
