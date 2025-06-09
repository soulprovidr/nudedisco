import Config

alias Nudedisco.Playlist
alias Nudedisco.Repo
alias Nudedisco.RSS
alias Nudedisco.Scheduler
alias Nudedisco.Spotify

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :nudedisco,
  port: 8080,
  ecto_repos: [Repo],
  admin_email: "shola@soulprovidr.fm"

config :nudedisco, Repo,
  database: "nudedisco.db",
  log: false

config :nudedisco, Scheduler,
  timezone: "America/Toronto",
  jobs: [
    # playlist_create: [
    #   schedule: "0 7 * * 5",
    #   task: {Playlist, :create, [[notify: true]]}
    # ],
    rss_sync: [
      schedule: "@hourly",
      task: {RSS.Sync, :run, []}
    ]
  ]

config :nudedisco, Spotify, listmonk_authorization_template_id: 4

case Config.config_env() do
  :dev ->
    config :nudedisco, Playlist,
      listmonk_playlist_list_id: 4,
      listmonk_playlist_template_id: 1,
      spotify_playlist_id: "098JzO5hMPu4sfy850iJNz"

  :test ->
    config :nudedisco, Playlist,
      listmonk_playlist_list_id: 4,
      listmonk_playlist_template_id: 1,
      spotify_playlist_id: "098JzO5hMPu4sfy850iJNz"

  :prod ->
    config :nudedisco, Playlist,
      listmonk_playlist_list_id: 3,
      listmonk_playlist_template_id: 1,
      spotify_playlist_id: "3FxuIvXkD3JvLKstWBLfff"
end
