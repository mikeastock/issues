defmodule Issues.GithubIssues do
  @user_agent "Elixir mikeastock@gmail.com"
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get([{ "User-Agent", @user_agent }])
    |> handle_response
  end

  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def handle_response({ :ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    { :ok, Poison.decode!(body, keys: :atoms) }
  end

  def handle_response({ :ok, %HTTPoison.Response{status_code: _, body: body}}) do
    { :error, Poison.decode!(body, keys: :atoms) }
  end
end
