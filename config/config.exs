import Config

config :nudedisco,
  port: 8080

config :nudedisco, Nudedisco.Scheduler,
  jobs: [
    rss_sync: [
      schedule: "@hourly",
      task: {Nudedisco.RSS, :sync_feeds!, []}
    ],
    playlist_update: [
      schedule: "0 7 * * 5",
      task: {Nudedisco.Playlist, :update, []}
    ]
  ]
