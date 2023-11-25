defmodule Nudedisco.Listmonk do
  alias Nudedisco.Listmonk
  alias Nudedisco.Util

  require Logger

  defp api_url(), do: Application.get_env(:nudedisco, Listmonk)[:api_url]
  defp admin_user(), do: Application.get_env(:nudedisco, Listmonk)[:admin_user]
  defp admin_password(), do: Application.get_env(:nudedisco, Listmonk)[:admin_password]

  defp get_authorization_header() do
    token = Base.encode64("#{admin_user()}:#{admin_password()}")
    {"Authorization", "Basic #{token}"}
  end

  @spec create_campaign(String.t(), String.t(), list()) :: :error | {:ok, any()}
  def create_campaign(subject, body, opts \\ []) do
    list_id = Keyword.get(opts, :list_id)
    template_id = Keyword.get(opts, :template_id)

    body =
      Poison.encode!(%{
        "name" => "nudedis.co: Fresh Fridays",
        "subject" => subject,
        "lists" => [list_id],
        "template_id" => template_id,
        "type" => "regular",
        "content_type" => "html",
        "body" => body
      })

    headers = [
      {"Content-Type", "application/json"},
      get_authorization_header()
    ]

    url = "#{api_url()}/campaigns"

    with {:ok, body} <- Util.request(:post, url, body, headers) do
      Logger.debug("[Listmonk] Successfully sent email.")
      %{"data" => %{"id" => campaign_id}} = Poison.decode!(body)
      {:ok, campaign_id}
    else
      _ ->
        Logger.debug("[Listmonk] Failed to send email.")
        :error
    end
  end

  @spec start_campaign(integer()) :: :error | {:ok, any()}
  def start_campaign(campaign_id) do
    body =
      Poison.encode!(%{
        "campaign_id" => campaign_id,
        "status" => "running"
      })

    headers = [
      {"Content-Type", "application/json"},
      get_authorization_header()
    ]

    url = "#{api_url()}/campaigns/#{campaign_id}/status"

    with {:ok, body} <- Util.request(:put, url, body, headers) do
      Logger.debug("[Listmonk] Successfully started campaign.")
      {:ok, body}
    else
      _ ->
        Logger.debug("[Listmonk] Failed to start campaign.")
        :error
    end
  end

  @spec create_subscriber(String.t()) :: :error | {:ok, any()}
  def create_subscriber(email, opts \\ []) do
    list_id = Keyword.get(opts, :list_id)

    body =
      Poison.encode!(%{
        "email" => email,
        "name" => String.split(email, "@") |> List.first(),
        "lists" => [list_id],
        "status" => "enabled"
      })

    headers = [
      {"Content-Type", "application/json"},
      get_authorization_header()
    ]

    url = "#{api_url()}/subscribers"

    with {:ok, body} <- Util.request(:post, url, body, headers) do
      Logger.debug("[Listmonk] Successfully created subscriber.")
      {:ok, body}
    else
      _ ->
        Logger.debug("[Listmonk] Failed to create subscriber.")
        :error
    end
  end
end
