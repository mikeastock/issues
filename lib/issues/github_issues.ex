defmodule Issues.GithubIssues do
  require Logger

  @user_agent "Elixir mikeastock@gmail.com"
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    Logger.info "Fetching user #{user}'s project #{project}"
    issues_url(user, project)
    |> HTTPoison.get([{ "User-Agent", @user_agent }])
    |> handle_response
  end

  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def handle_response({ :ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    Logger.info "Successful response"
    Logger.debug fn -> inspect(body) end
    { :ok, Poison.decode!(body, keys: :atoms) }
  end

  def handle_response({ :ok, %HTTPoison.Response{status_code: _, body: body}}) do
    Logger.error "Unccessfull response"
    Logger.error inspect(body)
    { :error, Poison.decode!(body, keys: :atoms) }
  end
end
