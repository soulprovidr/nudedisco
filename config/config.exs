import Config

alias Nudedisco.Listmonk
alias Nudedisco.OpenAI
alias Nudedisco.Playlist
alias Nudedisco.Scheduler

config :nudedisco,
  port: 8080

config :nudedisco, Scheduler,
  jobs: [
    playlist_sync: [
      schedule: "0 7 * * 5",
      task: {Playlist, :create, [notify: true]}
    ]
  ]
