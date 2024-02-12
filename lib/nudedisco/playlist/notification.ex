defmodule Nudedisco.Playlist.Notification do
  alias Nudedisco.Listmonk
  alias Nudedisco.Playlist

  require Logger

  @type opts :: [playlist_items: list(Playlist.Item.t())]

  @fresh_emojis ["🥝", "🍓", "🍇", "🥑", "🍒", "🍍", "🍋", "🍉", "🥭", "🫐", "🍎", "🍊"]

  @spec email_subject() :: String.t()
  defp email_subject() do
    date =
      DateTime.utc_now()
      |> Calendar.strftime("%m/%d")

    "nudedis.co's Fresh Fridays: your #{date} playlist is live ⚡️"
  end

  @spec email_body([Playlist.Item.t()]) :: String.t()
  defp email_body(playlist_items) do
    require EEx

    date = DateTime.utc_now() |> Calendar.strftime("%B %d, %Y")
    emoji = Enum.random(@fresh_emojis)

    EEx.eval_string(
      """
        <h2><%= date %>: what's fresh this week <%= emoji %></h2>
        <p>
          Get your weekend started with brand new music – reviewed by the Internet's top music minds, including Pitchfork, Bandcamp, and more.
        </p>
        <a
          class="button"
          href="https://open.spotify.com/playlist/<%= playlist_id %>">
          Listen on Spotify
        </a>
        <hr />
        <h3>This week's tracks:</h3>
        <table role="presentation">
        <%= for item <- playlist_items do %>
          <tr>
            <td>
              <img
                alt="Cover art for <%= item.album %> by <%= item.artist %>"
                class="cover"
                src="<%= item.image %>"
              />
            </td>
            <td>
              <div class="title"><%= item.title %></div>
              <div class="artist"><%= item.artist %></div>
            </td>
          </tr>
        <% end %>
        </table>
      """,
      date: date,
      emoji: emoji,
      playlist_id: Playlist.Constants.spotify_playlist_id(),
      playlist_items: playlist_items
    )
  end

  @spec send_email(list()) :: :error | {:ok, any()}
  defp send_email(playlist_items) do
    body = email_body(playlist_items) |> String.replace("\n", "")

    create_campaign_result =
      Listmonk.create_campaign(
        email_subject(),
        body,
        list_id: Playlist.Constants.listmonk_playlist_list_id(),
        template_id: Playlist.Constants.listmonk_playlist_template_id()
      )

    with {:ok, campaign_id} <- create_campaign_result,
         {:ok, _} <- Listmonk.start_campaign(campaign_id) do
      Logger.info("[Playlist] Successfully sent email.")
      {:ok, campaign_id}
    else
      _ ->
        Logger.error("[Playlist] Failed to send email.")
        :error
    end
  end

  @spec send(playlist_items: [Playlist.Item.t()]) :: :ok | {:error, String.t()}
  def send(opts \\ []) do
    playlist_items = Keyword.get(opts, :playlist_items, [])

    case playlist_items do
      [] ->
        Logger.info("[Playlist] No playlist items specified. Aborting...")
        {:error, "No playlist items specified."}

      _ ->
        Task.start(fn -> send_email(playlist_items) end)
        :ok
    end
  end
end
