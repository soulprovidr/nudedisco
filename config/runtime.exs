import Config
import SweetXml

alias Nudedisco.Listmonk
alias Nudedisco.OpenAI
alias Nudedisco.Playlist
alias Nudedisco.RSS
alias Nudedisco.Spotify

config :nudedisco, Listmonk,
  api_url: System.fetch_env!("LISTMONK_API_URL"),
  admin_user: System.fetch_env!("LISTMONK_ADMIN_USER"),
  admin_password: System.fetch_env!("LISTMONK_ADMIN_PASSWORD")

config :nudedisco, OpenAI, api_key: System.fetch_env!("OPENAI_API_KEY")

config :nudedisco, Spotify,
  client_id: System.fetch_env!("SPOTIFY_CLIENT_ID"),
  client_secret: System.fetch_env!("SPOTIFY_CLIENT_SECRET"),
  redirect_uri: System.fetch_env!("SPOTIFY_REDIRECT_URI")

config :nudedisco, RSS,
  configs: [
    RSS.Config.new(%{
      name: "Backseat Mafia",
      feed_url: "https://www.backseatmafia.com/category/album-reviews/feed/",
      site_url: "https://www.backseatmafia.com/category/album-reviews/",
      slug: :backseat_mafia
    }),
    RSS.Config.new(%{
      name: "Bandcamp Daily",
      feed_url: "https://daily.bandcamp.com/feed",
      site_url: "https://daily.bandcamp.com",
      slug: :bandcamp
    }),
    RSS.Config.new(%{
      name: "Beats Per Minute",
      feed_url: "https://beatsperminute.com/category/reviews/album-reviews/feed/",
      site_url: "https://beatsperminute.com/category/reviews/album-reviews/",
      slug: :beatsperminute
    }),
    RSS.Config.new(%{
      name: "The Guardian",
      feed_url: "https://www.theguardian.com/music+tone/albumreview/rss",
      site_url: "https://www.theguardian.com/music+tone/albumreview",
      slug: :the_guardian
    }),
    RSS.Config.new(%{
      name: "The Needledrop",
      feed_url: "https://www.theneedledrop.com/articles?format=rss",
      site_url: "https://www.theneedledrop.com/articles",
      slug: :the_needledrop,
      xpath_subspec: [image: ~x"./media:content/@url"s]
    }),
    RSS.Config.new(%{
      name: "NME",
      feed_url: "https://www.nme.com/reviews/album/feed",
      site_url: "https://www.nme.com/reviews/album",
      slug: :nme
    }),
    RSS.Config.new(%{
      name: "NPR",
      feed_url: "https://feeds.npr.org/1104/rss.xml",
      site_url: "https://www.npr.org/sections/music-reviews/",
      slug: :npr
    }),
    RSS.Config.new(%{
      name: "Pitchfork",
      feed_url: "https://pitchfork.com/feed/feed-album-reviews/rss",
      site_url: "https://pitchfork.com/reviews/albums/",
      slug: :pitchfork,
      xpath_subspec: [image: ~x"./media:thumbnail/@url"s]
    }),
    RSS.Config.new(%{
      name: "PopMatters",
      feed_url: "https://www.popmatters.com/category/music-reviews/feed",
      site_url: "https://www.popmatters.com/category/music-reviews",
      slug: :popmatters
    }),
    RSS.Config.new(%{
      name: "The Quietus",
      feed_url: "https://thequietus.com/reviews.atom",
      site_url: "https://thequietus.com",
      slug: :the_quietus,
      xpath_spec: ~x"//entry"l,
      xpath_subspec: [
        description: ~x"./content/text()"s,
        url: ~x"./link/@href"s,
        date: ~x"./published/text()"s |> transform_by(&Timex.parse!(&1, "{RFC3339z}"))
      ]
    }),
    RSS.Config.new(%{
      name: "Rolling Stone",
      feed_url: "https://www.rollingstone.com/music/music-album-reviews/feed/",
      site_url: "https://www.rollingstone.com/music/music-album-reviews/",
      slug: :rolling_stone
    })
  ]
