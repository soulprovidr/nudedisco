defmodule Nudedisco.Playlist.Constants do
  @email_subject "nudedis.co: this week's Fresh Fridays playlist is live! ⚡️"

  @spec email_subject() :: String.t()
  def email_subject(), do: @email_subject

  @spec email_body([Nudedisco.Playlist.Item.t()]) :: String.t()
  def email_body(playlist_items) do
    tracklist_rows =
      playlist_items
      |> Enum.map(fn item ->
        """
        <tr>
          <td>
            <img
              alt="Cover art for #{item.album} by #{item.artist}"
              class="cover"
              src="#{item.image}"
            />
          </td>
          <td>
            <div class="title">#{item.title}</div>
            <div class="artist">#{item.artist}</div>
          </td>
        </tr>
        """
      end)
      |> Enum.join("\r")

    """
    ## Fresh Fridays has arrived! 😎

    Get the week's newest releases across genres in one playlist, updated every Friday morning. Kickstart your weekend with fresh beats and emerging artists.

    <a
      class="button"
      href="https://open.spotify.com/playlist/098JzO5hMPu4sfy850iJNz">
      Listen on Spotify
    </a>

    <hr />

    ### Tracklist:
    <table role="presentation">
    #{tracklist_rows}
    </table>
    """
  end

  @system_prompt "Using the data present in an array of JSON objects representing RSS feed items for music album reviews, provide a JSON array containing a list of JSON objects of the following form: [{album: '<album>', artist: '<artist>'}, ...].

  Both the album and artist keys are required, and should not have associated values that represent null or undefined, such as 'N/A'. For any items where either the artist or album cannot be extracted or inferred, omit the corresponding object from the new list. In other words, only include objects where both album and artist are defined.

  The following are examples of bad results:

  - {'album': 'N/A', 'artist': 'N/A'}
  - {'album': 'N/A', 'artist': 'The Beatles'}
  - {'album': 'Abbey Road', 'artist': 'N/A'}
  - {'album': 'Abbey Road'}
  - {'artist': 'The Beatles'}

  When the artist name takes the form '<name> and ...', '<name> & ...', or '<name> (...)', omit everything after '<name>'.

  The following are examples of bad results:

  - {'album': 'Abbey Road', 'artist': 'The Beatles and Friends'}
  - {'album': 'Abbey Road', 'artist': 'The Beatles & Friends'}
  - {'album': 'Abbey Road', 'artist': 'The Beatles & The Other Guys'}
  - {'album': 'Abbey Road', 'artist': 'The Beatles (and Friends)'}

  Convert all special characters, such as 'ì' to their closest English equivalents.

  The following are examples of bad results:

  - [{'album': 'Abbey Road', 'artist': 'The Béatles'}]
  - [{'album': 'Äbbey Road', 'artist': 'The Beatles'}]

  Answer only with a JSON array and do not include any additional characters or text.

  The following is an example of the expected result:

  - [{'album': 'Abbey Road', 'artist': 'The Beatles'}]"

  @spec system_prompt() :: String.t()
  def system_prompt, do: @system_prompt

  def playlist_id(), do: Application.get_env(:nudedisco, :spotify_playlist_id)
end
