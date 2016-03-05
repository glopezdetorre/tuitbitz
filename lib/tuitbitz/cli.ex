defmodule Tuitbitz.CLI do

  @default_count 20
  @default_favs 0

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def process (:help) do
    IO.puts """
    usage: tuitbitz <term> [ count | #{@default_count} ]
    """
    System.halt(0)
  end

  def process({term, count}) do
    ExTwitter.search(term, [count: count])
    |> map_tweets
    |> print
  end

  def print([tweet|tweets]) do
    IO.puts """
    "@#{tweet.user}":
    #{tweet.text}
    [#{tweet.favs}❤ | #{tweet.retweets}♺]
    """
    print tweets
  end
  def print([]), do: nil

  def map_tweets(tweets) do
    Enum.map(
      tweets,
        fn (tweet) -> %{
          favs: tweet.favorite_count,
          retweets: tweet.retweet_count,
          user: tweet.user.name,
          text: tweet.text
        } end
    )
  end

  def parse_args(argv) do
    parse = OptionParser.parse(
      argv,
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    case parse do
      { [help: true], _, _ } -> :help
      { _, [term, count], _ } -> { term, String.to_integer(count) }
      { _, [term], _ } -> { term, @default_count }
      _ -> :help
    end
  end
end
