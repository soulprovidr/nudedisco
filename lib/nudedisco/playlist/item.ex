defmodule Nudedisco.Playlist.Item do
  defstruct [:album, :artist, :artist_id, :image, :title, :track_uri]

  @type t :: %__MODULE__{
          album: String.t(),
          artist: String.t(),
          artist_id: String.t(),
          image: String.t(),
          title: String.t(),
          track_uri: String.t()
        }
end
