defmodule Nudedisco.Listmonk do
  alias Nudedisco.Listmonk
  alias Nudedisco.Util

  def create_campaign(subject, body) do
    api_url = Listmonk.Constants.api_url()
    username = Listmonk.Constants.admin_user()
    password = Listmonk.Constants.admin_password()
    list_id = Listmonk.Constants.list_id()
    template_id = Listmonk.Constants.template_id()

    body =
      Poison.encode!(%{
        "name" => "nudedis.co: Fresh Fridays",
        "subject" => subject,
        "lists" => [list_id],
        "template_id" => template_id,
        "type" => "regular",
        "content_type" => "markdown",
        "body" => body
      })

    token = Base.encode64("#{username}:#{password}")

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Basic #{token}"}
    ]

    url = "#{api_url}/campaigns"

    with {:ok, body} <- Util.request(:post, url, body, headers) do
      IO.puts("[Listmonk] Successfully sent email.")
      %{"data" => %{"id" => campaign_id}} = Poison.decode!(body)
      {:ok, campaign_id}
    else
      _ ->
        IO.puts("[Listmonk] Failed to send email.")
        :error
    end
  end

  def start_campaign(campaign_id) do
    api_url = Listmonk.Constants.api_url()
    username = Listmonk.Constants.admin_user()
    password = Listmonk.Constants.admin_password()

    body =
      Poison.encode!(%{
        "campaign_id" => campaign_id,
        "status" => "running"
      })

    token = Base.encode64("#{username}:#{password}")

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Basic #{token}"}
    ]

    url = "#{api_url}/campaigns/#{campaign_id}/status"

    with {:ok, body} <- Util.request(:put, url, body, headers) do
      IO.puts("[Listmonk] Successfully started campaign.")
      {:ok, body}
    else
      _ ->
        IO.puts("[Listmonk] Failed to start campaign.")
        :error
    end
  end

  def create_subscriber(email) do
    api_url = Listmonk.Constants.api_url()
    username = Listmonk.Constants.admin_user()
    password = Listmonk.Constants.admin_password()
    list_id = Listmonk.Constants.list_id()

    body =
      Poison.encode!(%{
        "email" => email,
        "name" => "",
        "lists" => [list_id],
        "status" => "enabled"
      })

    token = Base.encode64("#{username}:#{password}")

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Basic #{token}"}
    ]

    url = "#{api_url}/subscribers"

    with {:ok, body} <- Util.request(:post, url, body, headers) do
      IO.puts("[Listmonk] Successfully created subscriber.")
      {:ok, body}
    else
      _ ->
        IO.puts("[Listmonk] Failed to create subscriber.")
        :error
    end
  end
end
