import Config

config :nudedisco,
  port: 8080

config :nudedisco, Nudedisco.Scheduler,
  jobs: [
    update_playlist: [
      schedule: "0 7 * * 5",
      task: {Nudedisco.Playlist, :update, []}
    ]
  ]
