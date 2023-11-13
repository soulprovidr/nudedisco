defmodule Nudedisco.Playlist.Item do
  defstruct [:album, :artist, :image, :title, :track_uri]

  @type t :: %__MODULE__{
          album: String.t(),
          artist: String.t(),
          image: String.t(),
          title: String.t(),
          track_uri: String.t()
        }
end
