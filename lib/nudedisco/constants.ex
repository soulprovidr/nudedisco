defmodule Nudedisco.Constants do
  @moduledoc false

  alias Nudedisco.RSSConfig, as: RSSConfig

  defmacro __using__(_) do
    quote do
      @default_xpath_spec ~x"//item"l
      @default_xpath_subspec [
        title: ~x"./title/text()"s,
        description: ~x"./description/text()"s,
        url: ~x"./link/text()"s,
        date: ~x"./pubDate/text()"s
      ]

      @feed_configs [
        %RSSConfig{
          name: "Backseat Mafia",
          feed_url: "https://www.backseatmafia.com/category/album-reviews/feed/",
          site_url: "https://www.backseatmafia.com/category/album-reviews/",
          slug: :backseat_mafia,
          xpath_spec: @default_xpath_spec,
          xpath_subspec: @default_xpath_subspec
        },
        %RSSConfig{
          name: "Bandcamp Daily",
          feed_url: "https://daily.bandcamp.com/feed",
          site_url: "https://daily.bandcamp.com",
          slug: :bandcamp,
          xpath_spec: @default_xpath_spec,
          xpath_subspec: @default_xpath_subspec
        },
        %RSSConfig{
          name: "Beats Per Minute",
          feed_url: "https://beatsperminute.com/category/reviews/album-reviews/feed/",
          site_url: "https://beatsperminute.com/category/reviews/album-reviews/",
          slug: :beatsperminute,
          xpath_spec: @default_xpath_spec,
          xpath_subspec: @default_xpath_subspec
        },
        %RSSConfig{
          name: "The Guardian",
          feed_url: "https://www.theguardian.com/music+tone/albumreview/rss",
          site_url: "https://www.theguardian.com/music+tone/albumreview",
          slug: :the_guardian,
          xpath_spec: @default_xpath_spec,
          xpath_subspec: @default_xpath_subspec
        },
        %RSSConfig{
          name: "The Needledrop",
          feed_url: "https://www.theneedledrop.com/articles?format=rss",
          site_url: "https://www.theneedledrop.com/articles",
          slug: :the_needledrop,
          xpath_spec: @default_xpath_spec,
          xpath_subspec: [
            title: ~x"./title/text()"s,
            description: ~x"./description/text()"s,
            image: ~x"./media:content/@url"s,
            url: ~x"./link/text()"s,
            date: ~x"./pubDate/text()"s
          ]
        },
        %RSSConfig{
          name: "NME",
          feed_url: "https://www.nme.com/reviews/album/feed",
          site_url: "https://www.nme.com/reviews/album",
          slug: :nme,
          xpath_spec: @default_xpath_spec,
          xpath_subspec: @default_xpath_subspec
        },
        %RSSConfig{
          name: "NPR",
          feed_url: "https://feeds.npr.org/1104/rss.xml",
          site_url: "https://www.npr.org/sections/music-reviews/",
          slug: :npr,
          xpath_spec: @default_xpath_spec,
          xpath_subspec: @default_xpath_subspec
        },
        %RSSConfig{
          name: "Pitchfork",
          feed_url: "https://pitchfork.com/feed/feed-album-reviews/rss",
          site_url: "https://pitchfork.com/reviews/albums/",
          slug: :pitchfork,
          xpath_spec: @default_xpath_spec,
          xpath_subspec: [
            title: ~x"./title/text()"s,
            description: ~x"./description/text()"s,
            image: ~x"./media:thumbnail/@url"s,
            url: ~x"./link/text()"s,
            date: ~x"./pubDate/text()"s
          ]
        },
        %RSSConfig{
          name: "PopMatters",
          feed_url: "https://www.popmatters.com/category/music-reviews/feed",
          site_url: "https://www.popmatters.com/category/music-reviews",
          slug: :popmatters,
          xpath_spec: @default_xpath_spec,
          xpath_subspec: @default_xpath_subspec
        },
        %RSSConfig{
          name: "The Quietus",
          feed_url: "https://thequietus.com/reviews.atom",
          site_url: "https://thequietus.com",
          slug: :the_quietus,
          xpath_spec: ~x"//entry"l,
          xpath_subspec: [
            title: ~x"./title/text()"s,
            description: ~x"./content/text()"s,
            url: ~x"./link/@href"s,
            date: ~x"./published/text()"s
          ]
        },
        %RSSConfig{
          name: "Rolling Stone",
          feed_url: "https://www.rollingstone.com/music/music-album-reviews/feed/",
          site_url: "https://www.rollingstone.com/music/music-album-reviews/",
          slug: :rolling_stone,
          xpath_spec: @default_xpath_spec,
          xpath_subspec: @default_xpath_subspec
        }
      ]
    end
  end
end
