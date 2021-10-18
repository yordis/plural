defmodule Core.Oauth.Github do
  use OAuth2.Strategy
  import System, only: [get_env: 1]
  require Logger

  def client() do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: get_env("GITHUB_CLIENT_ID"),
      client_secret: get_env("GITHUB_CLIENT_SECRET"),
      redirect_uri: "#{host()}/oauth/callback/github",
      site: "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token"
    ])
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  def authorize_url!() do
    OAuth2.Client.authorize_url!(client(), scope: "user")
  end

  def get_token!(code) do
    OAuth2.Client.get_token!(client(), code: code)
  end

  def get_user(client) do
    case OAuth2.Client.get(client, "/user") do
      {:ok, %OAuth2.Response{body: user}} ->
        {:ok, IO.inspect(user)}
      {:error, %OAuth2.Response{status_code: 401, body: body}} ->
        Logger.error("Unauthorized token, #{inspect(body)}")
        {:error, :unauthorized}
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

  defp host(), do: Application.get_env(:core, :host)
end