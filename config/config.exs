import Config

alias Nudedisco.Playlist
alias Nudedisco.RSS
alias Nudedisco.Scheduler

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :nudedisco,
  port: 8080

config :nudedisco, Scheduler,
  timezone: "America/Toronto",
  jobs: [
    playlist_create: [
      schedule: "0 7 * * 5",
      task: {Playlist, :create, [notify: true]}
    ],
    rss_sync: [
      schedule: "@hourly",
      task: {RSS, :sync, []}
    ]
  ]

IO.puts("config_env: #{config_env()}")
import_config("#{config_env()}.exs")
