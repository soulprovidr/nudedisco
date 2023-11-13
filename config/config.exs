import Config

alias Nudedisco.Playlist
alias Nudedisco.RSS
alias Nudedisco.Scheduler

config :nudedisco,
  port: 8080

config :nudedisco, Scheduler,
  jobs: [
    playlist_sync: [
      schedule: "0 7 * * 5",
      task: {Playlist, :sync!, []}
    ],
    rss_sync: [
      schedule: "@hourly",
      task: {RSS, :sync!, []}
    ]
  ]
