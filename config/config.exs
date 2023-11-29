import Config

alias Nudedisco.Playlist
alias Nudedisco.Scheduler

config :nudedisco,
  port: 8080

config :nudedisco, Scheduler,
  jobs: [
    playlist_create: [
      schedule: "0 7 * * 5",
      task: {Playlist, :create, [notify: true]}
    ],
    rss_sync: [
      schedule: "@hourly",
      task: {Playlist.RSS, :sync, []}
    ]
  ]
